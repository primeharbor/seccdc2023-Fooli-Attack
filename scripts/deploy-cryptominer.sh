#!/bin/bash

SUBNET=`aws ec2 describe-subnets --region us-east-1 --query Subnets[1].[SubnetId] --output text`
echo -n "Launching cryptominer... "
aws ec2 run-instances --region us-east-1 --image-id ami-0a25ed80a0ff1d536 --subnet-id $SUBNET --instance-type t2.micro --query Instances[].InstanceId --output text

