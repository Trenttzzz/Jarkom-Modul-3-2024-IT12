
echo 'nameserver 192.168.122.1' > /etc/resolv.conf

# Install DHCP server
apt-get update
apt-get install isc-dhcp-server -y

# Set the DHCP server configuration
interfaces='INTERFACESv4="eth0"
INTERFACESv6=""
'
echo '$interfaces' > /etc/default/isc-dhcp-server

# Set the DHCP server configuration
subnet='option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;

default-lease-time 600;
max-lease-time 7200;

ddns-update-style-none;

subnet 192.239.1.0 netmask 255.255.255.0 {
    range 192.239.1.05 192.239.1.25;
    range 192.239.1.50 192.239.1.100;
    option routers 192.239.1.0;
    option broadcast-address 192.239.1.255;
    option domain-name-servers 192.239.4.2;
    default-lease-time 3600;
    max-lease-time 5220;
}

subnet 192.239.2.0 netmask 255.255.255.0 {
    range 192.239.2.09 192.239.2.27;
    range 192.239.2.81 192.239.2.243;
    option routers 192.239.2.0;
    option broadcast-address 192.239.2.255;
    option domain-name-servers 192.239.4.2;
    default-lease-time 360;
    max-lease-time 5220;
}

subnet 192.239.3.0 netmask 255.255.255.0 {
}

subnet 192.239.4.0 netmask 255.255.255.0 {
}

'
echo "$subnet" > /etc/dhcp/dhcpd.conf

# Restart the service
service isc-dhcp-server restart