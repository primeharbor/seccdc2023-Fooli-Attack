#!/bin/bash

DATADIR=$1

if [ -z "$DATADIR" ] ; then
	echo "Usage: $0 <DATADIR>"
	exit 1
fi

echo -n "$0 " ; date

CONTAINER_ROLE=`cat $DATADIR/IAM-Roles.json | jq .Roles[].RoleName -r | grep ContainerRole`
aws iam attach-role-policy --role-name $CONTAINER_ROLE --policy-arn arn:aws:iam::aws:policy/AdministratorAccess