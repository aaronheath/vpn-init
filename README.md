# VPN-INIT

A collection of helper bash scripts to set up a VPN server and client(s).

## Prerequisites

It's assumed that the server is running Ubuntu 16.04 LTS.

## Scripts

All scripts are located in the 'cmds' directory. Must be executed as root.

### quick-start.sh

`./cmds/quick-start.sh 0.0.0.0`

From a remote client, which is assumed to be running Ubuntu 16.04, this script will provision a fresh Ubuntu 16.04 installation to act as a VPN server. Upon completion a connection to the VPN server will be established.

Replace 0.0.0.0 with the IP address of the remote server.

Should the file dh4096.pem be found in the repositories root path, this will be used as our key for the Diffie–Hellman key exchange. Otherwise, a 2048 bit key will be generated.

To verify that VPN connection has been established, run `ifconfig` and parse for a new interface.

### refresh-repository.sh

`./cmds/refresh-repository.sh`

Clones this repository into the /tmp/vpn-init dir. Should the repository already be cloned, a `git pull` is performed to being the repository up-to-date.

### create-client.sh

`./cmds/create-client.sh client_name`

Creates a new set of certificates for a client on the host.

Argument supplied will be used as the filename for the certificates.

### create-client-on-remote.sh

`./cmds/create-client-on-remote.sh 0.0.0.0 client_name`

Will create new set of certificates for a new client on remote host and copy them and the CA certificate back to the host (/etc/openvpn/).

Replace 0.0.0.0 with the IP address of the remote server.

Replace client_name with the desired name for the hosts certificates.

### server-init.sh

`./cmds/server-init.sh [eth0]`

Provisions the system to act as a VPN server. 

Optional argument can be to indicate the public network interface. Where not defined 'eth0' will be assumed.

Will look for a file at /tmp/dh4096.pem. If found this will be used as our key for the Diffie–Hellman key exchange. Otherwise, a 2048 bit key will be generated.

The script will also perform a dist-upgrade on the system. 
