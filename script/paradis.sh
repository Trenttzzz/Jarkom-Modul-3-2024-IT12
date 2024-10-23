#!/bin/bash

# Set the IP address of the interfaces
echo 'iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.239.0.0/16' >> .bashrc

# Install the DHCP relay package
apt-get update
apt install isc-dhcp-relay -y

# Set the DHCP relay configuration
dhcp_relay='
# Defaults for isc-dhcp-relay initscript
# sourced by /etc/init.d/isc-dhcp-relay
# installed at /etc/default/isc-dhcp-relay by the maintainer scripts

#
# This is a POSIX shell fragment
#

# What servers should the DHCP relay forward requests to?
SERVERS="192.239.4.1"

# On what interfaces should the DHCP relay (dhrelay) serve DHCP requests?
INTERFACES="eth1 eth2 eth3 eth4"

# Additional options that are passed to the DHCP relay daemon?
OPTIONS=""
'
echo "$dhcp_relay" > /etc/default/isc-dhcp-relay

# Enable IP forwarding
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.conf

# Restart the service
service isc-dhcp-relay restart