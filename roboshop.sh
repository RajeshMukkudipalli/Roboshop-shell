#!/bin/bash

ami_id=ami-09c813fb71547fc4f
sg_id=sg-0b267a41ee6ac45fc
instances=(
  "catalogue"
  "cart"
  "dispatch"
  "frontend"
  "mongodb"
  "mysql"
  "payment"
  "rabbitmq"
  "shipping"
  "redis"
  "user"
)
zone_id=Z078325528QCYPHSKGLAG
DomainName=devopsmaster.xyz
for instance in ${instances[@]}
do
  Instance_id=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --count 1 --instance-type t3.micro  --security-group-ids sg-0b267a41ee6ac45fc --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=test}]" --query 'Instances[0].InstanceId' --output text)
  if [ $instance != "frontend" ]
  then
      IP=$(aws ec2  describe-instances --instance-ids $Instance_id --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
  else
      IP=$(aws ec2  describe-instances --instance-ids $Instance_id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    
  fi
  echo "$Instance_id Ip address: $IP"

done