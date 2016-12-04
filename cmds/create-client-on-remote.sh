#!/usr/bin/env bash

# -------------------------------------------------------
# Remotely create new client
# -------------------------------------------------------
# Creates a new OpenVPN clients certificates from the client itself. Then, fetches these certificates and installs
# them locally. Finally restarts the service to being the vpn connection up.

set -e

SETUP_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${SETUP_PATH}/lib.sh

SERVER=$1
CLIENT_NAME=$2

is_root

## We must be supplied with the IP/Domain of the remote server.
must_have $1 "IP address of remote server not supplied."

## We must be supplied with the name to use for clients certificates.
must_have $2 "Client name for the clients certificates not supplied."

## Creates new client on the server.
ssh root@${SERVER} 'bash -s' < ${SETUP_PATH}/create-client.sh ${CLIENT_NAME}

## Rsync ca.crt from server back to client
rsync -avzse ssh --include 'ca.crt' --exclude '*' root@${SERVER}:/etc/openvpn/ /etc/openvpn/

## Rsync clients certificates from server back to client
rsync -avzse ssh --include "${CLIENT_NAME}.key" --include "${CLIENT_NAME}.crt" --exclude '*' \
 root@${SERVER}:/etc/openvpn/easy-rsa/keys/ /etc/openvpn/
