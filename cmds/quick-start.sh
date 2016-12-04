#!/usr/bin/env bash

# -------------------------------------------------------
# Quick Client & Server Setup
# -------------------------------------------------------
# From a client machine, setup a fresh server to act as our exclusive VPN serer.

set -e

START=`date +%s`

SETUP_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${SETUP_PATH}/lib.sh

SERVER=$1
CLIENT_NAME="client1"

is_root

## We must be supplied with the IP/Domain of the remote server.
must_have ${SERVER} "IP address of remote server not supplied."

## Copy our default public ssh key to the remote server.
ssh-copy-id -i ~/.ssh/id_rsa.pub ${SERVER}

if [ -a ${SETUP_PATH}/../dh4096.pem ]; then
    scp ${SETUP_PATH}/../dh4096.pem root@${SERVER}:/tmp/dh4096.pem
fi

## Upload and execute server-setup.sh on the remote server
ssh root@${SERVER} 'bash -s' < ${SETUP_PATH}/refresh-repository.sh
ssh root@${SERVER} 'bash -s' < ${SETUP_PATH}/server-init.sh

## Create a new client on the remote server and fetch certificates.
. ${SETUP_PATH}/create-client-on-remote.sh ${SERVER} ${CLIENT_NAME}

## Using fetched certificates, configure our local client.
sed -i "s/^remote .*/remote ${SERVER} 1194/g" /etc/openvpn/client.conf
sed -i "s/^cert client.crt/cert ${CLIENT_NAME}.crt/g" /etc/openvpn/client.conf
sed -i "s/^key client.key/key ${CLIENT_NAME}.key/g" /etc/openvpn/client.conf

## Restart the local client.
systemctl restart openvpn@client

END=`date +%s`
RUNTIME=$(((END - START) / 60))

echo "This VM took $RUNTIME minutes to setup."

echo '----------------------------'
echo '----------- END ------------'
echo '----------------------------'
