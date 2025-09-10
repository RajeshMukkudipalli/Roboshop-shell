#!/usr/bin/env bash
set -euo pipefail

ami_id='ami-09c813fb71547fc4f'
sg_id='sg-0b267a41ee6ac45fc'
INSTANCES=(catalogue cart dispatch frontend mongodb mysql payment rabbitmq shipping redis user)
zone_id='Z078325528QCYPHSKGLAG'
DomainName='devopsmaster.xyz'

for instance in "${INSTANCES[@]}"; do
  echo "Launching instance: $instance"

  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$ami_id" \
    --instance-type t2.micro \
    --security-group-ids "$sg_id" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query "Instances[0].InstanceId" \
    --output text)

  if [[ -z "$INSTANCE_ID" || "$INSTANCE_ID" == "None" ]]; then
    echo "ERROR: failed to get InstanceId for $instance. Skipping." >&2
    continue
  fi

  echo "Launched $instance as $INSTANCE_ID. Waiting until running..."
  aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

  if [[ "$instance" != "frontend" ]]; then
    IP=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query "Reservations[0].Instances[0].PrivateIpAddress" \
      --output text)
    Record_name="${instance}.${DomainName}"
  else
    IP=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query "Reservations[0].Instances[0].PublicIpAddress" \
      --output text)
    Record_name="${DomainName}"
  fi

  if [[ -z "$IP" || "$IP" == "None" ]]; then
    echo "WARNING: no IP found for $INSTANCE_ID (instance: $instance). Skipping DNS update." >&2
    continue
  fi

  echo "$instance IP address: $IP"

  change_batch=$(cat <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${Record_name}",
        "Type": "A",
        "TTL": 60,
        "ResourceRecords": [
          { "Value": "${IP}" }
        ]
      }
    }
  ]
}
EOF
)

  aws route53 change-resource-record-sets --hosted-zone-id "$zone_id" --change-batch "$change_batch"
  echo "Route53 updated: ${Record_name} -> ${IP}"
done
