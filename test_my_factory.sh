#!/bin/bash

FACTORY_NAME=$1
if [[ -s "$FACTORY_NAME" ]] ; then
	echo "USAGE: $0 <FactoryName>"
	exit 1
fi

echo "Testing factory for ${FACTORY_NAME}.fooli.wtf"
echo "--------"

echo -n "Testing API for ${FACTORY_NAME} - https://fooli-api.${FACTORY_NAME}.fooli.wtf - Number of Memes Returned: "
curl -s https://fooli-api.${FACTORY_NAME}.fooli.wtf/meme/ | jq '.[].meme_filename' | wc -l

echo -n "Payments healthcheck - https://payments.${FACTORY_NAME}.fooli.wtf - Status: "
curl -s https://payments.${FACTORY_NAME}.fooli.wtf -k | jq -r .HealthCheck

echo -n "Testing Rendered Meme Media Access - RussianWarship.png (HTTP 200 expected): "
curl -s https://memes.${FACTORY_NAME}.fooli.wtf/RussianWarship.png -I | head -1

echo -n "Testing Source Image Media Access - ContainerShipFire.jpg (HTTP 200 expected): "
curl -s https://fooli-${FACTORY_NAME}-0.s3.amazonaws.com/ContainerShipFire.jpg -I | head -1


# echo -n "Testing Source Image Media CDN Access - ContainerShipFire.jpg (200 expected): "
# curl -s https://memes.${FACTORY_NAME}.fooli.wtf/images.html # -I # | head -1
