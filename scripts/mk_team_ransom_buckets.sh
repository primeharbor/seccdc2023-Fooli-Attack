#!/bin/bash

SUFFIX=$1

if [[ -z "$SUFFIX" ]] ; then
  echo "Usage: $0 <SUFFIX>"
  exit 1
fi

for city in `cat cities.txt` ; do
	BUCKET="$city.fooli.wtf-$SUFFIX"
	aws s3 mb s3://$BUCKET
	aws s3api put-bucket-acl --bucket $BUCKET --grant-full-control  uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers
done