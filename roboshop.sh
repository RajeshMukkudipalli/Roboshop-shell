#!/bin/bash

ami_id="ami-09c813fb71547fc4f"
sg_id="sg-0b267a41ee6ac45fc"
INSTANCES=("catalogue" "cart" "dispatch" "frontend" "mongodb" "mysql" "payment" "rabbitmq" "shipping" "redis" "user")
zone_id="Z078325528QCYPHSKGLAG"
DomainName="'devopsmaster.xyz"

for instance in ${INSTANCES[@]}

do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f  --instance-type t2.micro  --security-group-ids sg-0b267a41ee6ac45fc --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
      IP=$(aws ec2  describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
      
    else
      IP=$(aws ec2  describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
      
    fi
      echo "$instance Ip address: $IP"

      aws route53 change-resource-record-sets \
  --hosted-zone-id $zone_id \
  --change-batch '{
    "Comment": "Creating or updating a record set for roboshop project",
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "'$instance'.'$DomainName'",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [{
          "Value": "'$IP'"
        }]
      }
    }]
  }'

done