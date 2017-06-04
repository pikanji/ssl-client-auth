#!/bin/bash
# This script creates your own root authority certificates.
# Based on the answer in StackOverflow: https://stackoverflow.com/a/43666288

if [ ! -f .env ]; then
    echo "Please provide .env file. See .env.dist for example."
    exit
fi

source .env

echo "COUNTRY: " $COUNTRY
echo "STATE: " $STATE
echo "LOCALITY: " $LOCALITY
echo "ORGANIZATION: " $ORGANIZATION
echo "ORGANIZATION_UNIT: " $ORGANIZATION_UNIT
echo "DOMAIN: " $DOMAIN
echo "COMMON_NAME: " $ORGANIZATION
echo "NUM_OF_DAYS: " $NUM_OF_DAYS

SUBJECT="/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/CN=$ORGANIZATION"

echo "SUBJECT: " $SUBJECT

openssl genrsa -out root_ca.key 2048
openssl req -x509 -new -nodes -days $NUM_OF_DAYS -key root_ca.key -sha256 -out root_ca.crt -subj "$SUBJECT"
