#!/usr/bin/env bash

## Update the OS

apt-get update
apt-get upgrade -y

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

## Setup Easy RSA

source ./vars
./clean-all

## Create Certificates

./pkitool --initca MyVPN
./pkitool --server server
./build-dh
cd keys/
cp server.crt server.key ca.crt dh2048.pem /etc/openvpn/
cd /etc/openvpn/easy-rsa/
source ./vars
./pkitool client1

## Setup Default OpenVPN Config

cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
gzip -d -f /etc/openvpn/server.conf.gz

## Modify Default OpenVPN Config

sed -i 's/dh dh1024.pem/dh dh2048.pem/g' /etc/openvpn/server.conf
sed -i 's/;push "redirect-gateway def1 bypass-dhcp"/push "redirect-gateway def1 bypass-dhcp"/g' /etc/openvpn/server.conf

## Enable ipv4 IP Forwarding

sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

## Update IP Tables

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

## Start the OpenVPN Service

service openvpn restart
