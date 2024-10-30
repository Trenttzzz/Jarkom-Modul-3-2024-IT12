#!/bin/bash
# 1. Install bind9
echo 'nameserver 192.168.122.1' > /etc/resolv.conf

apt-get update
apt-get install bind9 -y

# 2. Set the DNS server configuration
conf_local='
zone "eldia.it12.com" {
        type master;
        file "/etc/bind/jarkom/eldia.it12.com";
};

zone "marley.it12.com" {
        type master;
        file "/etc/bind/jarkom/marley.it12.com";
};'

echo "$conf_local" > /etc/bind/named.conf.local


options='
options {
        directory "/var/cache/bind";
        forwarders {
                192.168.122.1;
        };
        allow-query{any;};
        listen-on-v6 { any; };
};'

echo "$options" > /etc/bind/named.conf.options

mkdir /etc/bind/jarkom

eldia='
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     eldia.it12.com. root.eldia.it12.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      eldia.it12.com.
@       IN      A       192.239.2.1'

echo "$eldia" > /etc/bind/jarkom/eldia.it12.com

marley='
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     marley.it12.com. root.marley.it12.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      marley.it12.com.
@       IN      A       192.239.1.1'

echo "$marley" > /etc/bind/jarkom/marley.it12.com

# restart the service
service bind9 restart