#!/bin/bash

# Konfigurasi nameserver
echo nameserver 192.239.4.2 > /etc/resolv.conf

# Update dan install paket yang diperlukan
apt-get update
apt-get install apache2-utils -y   
apt-get install nginx -y           
apt-get install lynx -y            

# Konfigurasi Nginx untuk load balancing menggunakan PHP load balancer
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/colossal_lb

# Tambahkan konfigurasi load balancing
echo '
    upstream php_backend {
        server 192.239.2.1;  # Armin
        server 192.239.2.2;  # Eren
        server 192.239.2.3;  # Mikasa
    }

    server {
        listen 80;
        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;
        server_name _;

        location / {
            proxy_pass http://php_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
' > /etc/nginx/sites-available/colossal_lb

# Aktifkan konfigurasi load balancer
ln -sf /etc/nginx/sites-available/colossal_lb /etc/nginx/sites-enabled/

# Hapus default jika masih ada
if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi

#!/bin/bash

# Konfigurasi Round Robin
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/round_robin

echo '
    upstream round-robin {
        server 192.239.2.1;  # Armin
        server 192.239.2.2;  # Eren
        server 192.239.2.3;  # Mikasa
    }

    server {
        listen 1111;
        root /var/www/html;

        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
            proxy_pass http://round-robin;
        }
    }
' > /etc/nginx/sites-available/round_robin

# Konfigurasi Weighted Round Robin
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/weight_round_robin

echo '
    upstream weight_round-robin {
        server 192.239.2.1 weight=3;
        server 192.239.2.2 weight=2;
        server 192.239.2.3 weight=1;
    }

    server {
        listen 1112;
        root /var/www/html;

        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
            proxy_pass http://weight_round-robin;
        }
    }
' > /etc/nginx/sites-available/weight_round_robin

# Konfigurasi Generic Hash
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/generic_hash

echo '
    upstream generic_hash {
        hash $request_uri consistent;
        server 192.239.2.1 weight=3;
        server 192.239.2.2 weight=2;
        server 192.239.2.3 weight=1;
    }

    server {
        listen 1113;
        root /var/www/html;

        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
            proxy_pass http://generic_hash;
        }
    }
' > /etc/nginx/sites-available/generic_hash

# Konfigurasi IP Hash
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/ip_hash

echo '
    upstream ip_hash {
        ip_hash;
        server 192.239.2.1;  # Armin
        server 192.239.2.2;  # Eren
        server 192.239.2.3;  # Mikasa
    }

    server {
        listen 1114;
        root /var/www/html;

        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
            proxy_pass http://ip_hash;
        }
    }
' > /etc/nginx/sites-available/ip_hash

# Konfigurasi Least Connections
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/least_connection

echo '
    upstream least_connection {
        least_conn;
        server 192.239.2.1;  # Armin
        server 192.239.2.2;  # Eren
        server 192.239.2.3;  # Mikasa
    }

    server {
        listen 1115;
        root /var/www/html;

        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
            proxy_pass http://least_connection;
        }
    }
' > /etc/nginx/sites-available/least_connection

# Aktifkan semua konfigurasi load balancer
ln -sf /etc/nginx/sites-available/round_robin /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/weight_round_robin /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/generic_hash /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/ip_hash /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/least_connection /etc/nginx/sites-enabled/


# Restart layanan Nginx agar konfigurasi baru berlaku
service nginx restart