#!/bin/bash

CITY=$1

if [[ -z "$CITY" ]] ; then
  echo "Usage: $0 <CITY>"
  exit 1
fi

DATADIR=data/$CITY

if [ ! -d $DATADIR ] ; then
	mkdir -p $DATADIR
fi

if [ -z "$2" ] ; then
	USERNAME="security-audit"
else
	USERNAME=$2
fi

echo -n "$0 " ; date

aws iam create-user --user-name $USERNAME
aws iam attach-user-policy --user-name $USERNAME --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam create-access-key --user-name $USERNAME >> $DATADIR/${USERNAME}-creds.txt
