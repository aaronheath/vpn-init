#!/usr/bin/env bash

# -------------------------------------------------------
# Provision new client
# -------------------------------------------------------
# Creates a new client on the server and restarts the service.

set -e

. /tmp/vpn-init/cmds/lib.sh

CLIENT_NAME=$1

is_root

## We must be supplied with the name to use for clients certificates.
must_have $1 "Client name for the clients certificates not supplied."

## Create certificates for new client
cd /etc/openvpn/easy-rsa/
source ./vars
./pkitool ${CLIENT_NAME}

## Restart openvpn on the server
systemctl restart openvpn@server
