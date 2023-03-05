#!/bin/bash

CITY=$1

if [[ -z "$CITY" ]] ; then
  echo "Usage: $0 <CITY>"
  exit 1
fi

DATADIR=data/$CITY

source $CITY-container-creds.env


aws cloudformation delete-stack --stack-name meme-audit


aws iam detach-user-policy --user-name security-audit --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam delete-access-key --user-name security-audit --access-key-id `cat data/$CITY/security-audit-creds.txt | jq -r .AccessKey.AccessKeyId`
aws iam delete-user --user-name security-audit