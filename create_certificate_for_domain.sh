#!/bin/bash
# This script creates your server certificates and .p12 file for client authentication.
# Based on the answer in StackOverflow: https://stackoverflow.com/a/43666288

if [ ! -f .env ]; then
    echo "Please provide .env file. See .env.dist for example."
    exit
fi

source .env

COMMON_NAME=${COMMON_NAME:-*.$DOMAIN}

echo "COUNTRY: $COUNTRY"
echo "STATE: $STATE"
echo "LOCALITY: $LOCALITY"
echo "ORGANIZATION: $ORGANIZATION"
echo "ORGANIZATION_UNIT: $ORGANIZATION_UNIT"
echo "DOMAIN: $DOMAIN"
echo "COMMON_NAME: $COMMON_NAME"
echo "NUM_OF_DAYS: $NUM_OF_DAYS"

SUBJECT="/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/CN=$COMMON_NAME"

echo "SUBJECT: $SUBJECT"

openssl req -new -newkey rsa:2048 -sha256 -nodes -keyout server.key -subj "$SUBJECT" -out server.csr
cat v3.ext | sed s/%%DOMAIN%%/$COMMON_NAME/g > /tmp/__v3.ext
openssl x509 -req -in server.csr -CA root_ca.crt -CAkey root_ca.key -CAcreateserial -out server.crt -days $NUM_OF_DAYS -sha256 -extfile /tmp/__v3.ext

# Create p12 file for client
openssl pkcs12 -export -inkey server.key -in server.crt -certfile root_ca.crt -out $DOMAIN.p12

# move output files to final filenames
mv server.csr $DOMAIN.csr
cp server.crt $DOMAIN.crt

# remove temp file
rm -f server.crt;

echo
echo "###########################################################################"
echo Done!
echo "###########################################################################"
echo "To use these files on your server, simply copy both $DOMAIN.csr and"
echo "server.key to your webserver, and use like so (if Apache, for example)"
echo
echo "    SSLCertificateFile    /path_to_your_files/$DOMAIN.crt"
echo "    SSLCertificateKeyFile /path_to_your_files/server.key"
echo
echo "To install the certificates on local machine, double click on the .p12 file."
echo "In 'Keychain Access' set the installed root CA to 'Always Trust'."
