#!/usr/bin/env bash

# -------------------------------------------------------
# Provision Server
# -------------------------------------------------------
# Provisions a fresh installation to be an OpenVPN server.

set -e

## Public Interface
PUBLIC_INTERFACE=$1

if [ $# -eq 0 ]; then
    PUBLIC_INTERFACE="eth0"
fi

if [ -a /tmp/dh4096.pem ]; then
    USE_SUPPLIED_DH4096_KEYS="true"
else
    USE_SUPPLIED_DH4096_KEYS="false"
fi

## Update repositories and upgrade the OS
apt-get update
apt-get dist-upgrade -y

# Install OpenVPN and Easy RSA
apt-get install -y openvpn easy-rsa

## Create and go to easy-rsa dir
mkdir /etc/openvpn/easy-rsa/
cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
cd /etc/openvpn/easy-rsa/

## Configure Easy RSA
echo "export KEY_NAME=MyVPN" >> /etc/openvpn/easy-rsa/vars
echo "export KEY_OU=MyVPN" >> /etc/openvpn/easy-rsa/vars
echo "export KEY_ALTNAMES=MyVPN" >> /etc/openvpn/easy-rsa/vars

if [ ${USE_SUPPLIED_DH4096_KEYS} = "true" ]; then
    echo "export KEY_SIZE=4096" >> /etc/openvpn/easy-rsa/vars
fi

## Setup Easy RSA
. ./vars
./clean-all

## Create Certificates
./pkitool --initca MyVPN
./pkitool --server server
cd keys/
cp server.crt server.key ca.crt /etc/openvpn/

## Generate / Copy DH Keys
if [ ${USE_SUPPLIED_DH4096_KEYS} = "true" ]; then
    mv /tmp/dh4096.pem /etc/openvpn/
else
    . /etc/openvpn/easy-rsa/build-dh
    cp dh2048.pem /etc/openvpn/
fi

## Setup Default OpenVPN Config
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
gzip -d -f /etc/openvpn/server.conf.gz

## Modify Default OpenVPN Config
sed -i 's/;push "redirect-gateway def1 bypass-dhcp"/push "redirect-gateway def1 bypass-dhcp"/g' /etc/openvpn/server.conf
if [ ${USE_SUPPLIED_DH4096_KEYS} = "true" ]; then
    sed -i 's/dh dh2048\.pem/dh dh4096\.pem/g' /etc/openvpn/server.conf
fi

## Enable ipv4 IP Forwarding
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

## Update IP Tables
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ${PUBLIC_INTERFACE} -j MASQUERADE

## Start the OpenVPN Service
systemctl restart openvpn@server
