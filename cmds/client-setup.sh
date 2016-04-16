#!/usr/bin/env bash

## Verify that the script is being run as 'root'

current_user=`whoami`

if [ $current_user != "root" ];
then
    echo "Not running as 'root'. Currently '$current_user'."
    exit 1
fi

## Verify that we were supplied the remote servers IP address

if [ -z "$1" ]
then
    echo "IP address of remote server not supplied."
    exit 1
fi

## Upload the server-setup.sh script to the remote host

rsync -avzse ssh ./server-setup.sh root@${1}:/

## Halt the script until the user gives us the go ahead that the server has been setup

echo "\n\n\The script has been halted until the user indicates that the remote server has been setup.\n\n"
echo

read -p "When ready to continue press [Y] " -n 1 -r

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

## Wait until the remote server has been setup then continue the execution of this script

rsync -avzse ssh --include 'ca.crt' --exclude '*' root@${1}:/etc/openvpn/ /etc/openvpn/

rsync -avzse ssh --include 'client1.key' --include 'client1.crt' --exclude '*' root@${1}:/etc/openvpn/easy-rsa/keys/ /etc/openvpn/

sed -i "s/^remote .*/remote $1 1194/g" /etc/openvpn/client.conf

service openvpn restart
