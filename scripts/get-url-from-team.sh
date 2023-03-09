#!/bin/bash

TEAM=$1
url=`grep $TEAM LambdaURLs.txt | awk '{print $NF}'`
curl -s $url > creds.json
unset AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID  AWS_SESSION_TOKEN
export AWS_SECRET_ACCESS_KEY=`cat creds.json | jq .AWS_SECRET_ACCESS_KEY -r`
export AWS_ACCESS_KEY_ID=`cat creds.json | jq .AWS_ACCESS_KEY_ID -r `
export AWS_SESSION_TOKEN=`cat creds.json | jq .AWS_SESSION_TOKEN -r `
export AWS_DEFAULT_REGION=us-east-1
./scripts/get_login_url.py