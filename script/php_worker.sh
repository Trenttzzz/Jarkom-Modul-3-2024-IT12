#!/bin/bash

# Tambahkan nameserver
echo nameserver 192.239.4.2 >> /etc/resolv.conf

# Update dan install paket
apt-get update
apt-get install nginx -y
apt-get install lynx -y
apt-get install php7.3 php7.3-fpm php7.3-mysql -y   
apt-get install wget -y
apt-get install unzip -y
apt-get install rsync -y    

# Start service Nginx dan PHP-FPM
service nginx start
service php7.3-fpm start    

# Download file zip modul-3
wget --no-check-certificate 'https://drive.google.com/uc?export=download&id=1ufulgiWyTbOXQcow11JkXG7safgLq1y-' -O '/var/www/modul-3.zip'

# Extract file zip modul-3
unzip -o /var/www/modul-3.zip -d /var/www/
rm /var/www/modul-3.zip

# Copy isi folder modul-3 ke marley.it12.com
rsync -av /var/www/modul-3/ /var/www/marley.it12.com/

# Hapus folder modul-3
rm -r /var/www/modul-3

# Konfigurasi Nginx
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/marley.it12.com

# Periksa apakah symbolic link sudah ada, jika iya, hapus
if [ -L /etc/nginx/sites-enabled/marley.it12.com ]; then
    rm /etc/nginx/sites-enabled/marley.it12.com
fi

# Buat symbolic link baru
ln -s /etc/nginx/sites-available/marley.it12.com /etc/nginx/sites-enabled/

# Hapus konfigurasi default
if [ -L /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi

# Konfigurasi Nginx
echo 'server {
     listen 80;
     server_name _;

     root /var/www/marley.it12.com/;
     index index.php index.html index.htm;

     location / {
         try_files $uri $uri/ /index.php?$query_string;
     }

     location ~ \.php$ {
         include snippets/fastcgi-php.conf;
         fastcgi_pass unix:/run/php/php7.3-fpm.sock;
         fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
         include fastcgi_params;
     }
 }' > /etc/nginx/sites-available/marley.it12.com

# Restart Nginx dan PHP-FPM 7.3
service php7.3-fpm restart
service nginx restart