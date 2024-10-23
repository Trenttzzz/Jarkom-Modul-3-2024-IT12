# Laporan Praktikum Jarkom Modul 3 2024

## Kelompok IT 12

### Topologi

![image](https://github.com/user-attachments/assets/12cfc2bc-e705-4bc4-8834-9d2682ef0898)


### Network Configuration

- **Paradis (DHCP Relay)**
    ```
    auto eth0
    iface eth0 inet dhcp

    auto eth1
    iface eth1 inet static
        address 192.239.1.0
        netmask 255.255.255.0

    auto eth2
    iface eth2 inet static
        address 192.239.2.0
        netmask 255.255.255.0

    auto eth3
    iface eth3 inet static
        address 192.239.3.0
        netmask 255.255.255.0

    auto eth4
    iface eth4 inet static
        address 192.239.4.0
        netmask 255.255.255.0
    ```
- **Tybur (DHCP Server)**
    ```
    auto eth0
    iface eth0 inet static
        address 192.239.4.1
        netmask 255.255.255.0
        gateway 192.239.4.0
    ```
- **Fritz (DNS Server)**
    ```
    auto eth0
    iface eth0 inet static
        address 192.239.4.2
        netmask 255.255.255.0
        gateway 192.239.4.0
    ```
- **Collosal (Load Balancer)**
    ```
    auto eth0
    iface eth0 inet static
        address 192.239.3.2
        netmask 255.255.255.0
        gateway 192.239.3.0
    ```
- **Beast (Load Balancer)**
    ```
    auto eth0
    iface eth0 inet static
        address 192.239.3.1
        netmask 255.255.255.0
        gateway 192.239.3.0
    ```
- **Warhammer (Database Server)**
    ```
    auto eth0
    iface eth0 inet static
        address 192.239.3.3
        netmask 255.255.255.0
        gateway 192.239.3.0
    ```
- **Armin (PHP Worker)**
    ```
    auto eth0
    iface eth0 inet static
        address 192.239.2.1
        netmask 255.255.255.0
        gateway 192.239.2.0
    ```
- **Eren (PHP Worker)**
    ```
    auto eth0
    iface eth0 inet static
        address 192.239.2.2
        netmask 255.255.255.0
        gateway 192.239.2.0
    ```
- **Mikasa (PHP Worker)**
    ```
    auto eth0
    iface eth0 inet static
        address 192.239.2.3
        netmask 255.255.255.0
        gateway 192.239.2.0
    ```
- **Annie (Laravel Worker)**
    ```
    auto eth0
    iface eth0 inet static
        address 192.239.1.1
        netmask 255.255.255.0
        gateway 192.239.1.0
    ```
- **Bertholdt (Laravel Worker)**
    ```
    auto eth0
    iface eth0 inet static
        address 192.239.1.2
        netmask 255.255.255.0
        gateway 192.239.1.0
    ```
- **Reiner (Laravel Worker)**
    ```
    auto eth0
    iface eth0 inet static
        address 192.239.1.3
        netmask 255.255.255.0
        gateway 192.239.1.0
    ```
- **Zeke, Erwin (Client)**
    ```
    auto eth0
    iface eth0 inet dhcp
    ```

### Langkah - Langkah

#### Nomor 1
> Membuat Domain Name dengan nama `marley.it12.com` menuju **Annie** dan `eldia.it12.com` menuju **Armin**

- Buat script untuk **Fritz (DNS Server)** dengan nama `fritz.sh`
    ```
    #!/bin/bash
    # 1. Install bind9
    echo 'nameserver 192.169.122.1' > /etc/resolv.conf

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
    ```
- Tes dengan ketik `ping marley.it12.com` dan `ping eldia.it12.com` pada **client**
    ![image](https://github.com/user-attachments/assets/997a107e-6196-4ee4-b011-f026e1394f0e)

#### Nomor 2-5

>Semua Client harus menggunakan konfigurasi ip address dari keluarga Tybur (dhcp).
>Client yang melalui bangsa marley mendapatkan range IP dari [prefix IP].1.05 - [prefix IP].1.25 dan [prefix IP].1.50 - [prefix IP].1.100 (2)
>Client yang melalui bangsa eldia mendapatkan range IP dari [prefix IP].2.09 - [prefix IP].2.27 dan [prefix IP].2 .81 - [prefix IP].2.243 (3)
>Client mendapatkan DNS dari keluarga Fritz dan dapat terhubung dengan internet melalui DNS tersebut (4)
>Dikarenakan keluarga Tybur tidak menyukai kaum eldia, maka mereka hanya meminjamkan ip address ke kaum eldia selama 6 menit. Namun untuk kaum marley, keluarga Tybur meminjamkan ip address selama 30 menit. Waktu maksimal dialokasikan untuk peminjaman alamat IP selama 87 menit. (5)

- Buat Script untuk **Tybur (DHCP Server)** dengan nama `tybur.sh`
    ```

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
    ```

- Buat Script untuk **Paradis DHCP Relay** dengan nama `paradis.sh`
    ```
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
    ```
- Tes dengan login ke salah satu client dan, coba cek ip nya dengan `ip a`
    ![image](https://github.com/user-attachments/assets/235227b7-7672-4001-b844-e06e053d4277)

#### Nomor 6
> Armin berinisiasi untuk memerintahkan setiap worker PHP untuk melakukan konfigurasi virtual host untuk website berikut https://intip.in/BangsaEldia dengan menggunakan php 7.3 (6)

- Buat script untuk setiap **php-worker** bernama `php_worker.sh`
    ```
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
    ```
- Tes dengan ketik `lynx http://192.239.2.1` pada salah satu **client**
    ![image](https://github.com/user-attachments/assets/5bef413c-27bf-4d0e-b75f-8ad9adc41d08)

#### Nomor 7

> Dikarenakan Armin sudah mendapatkan kekuatan titan colossal, maka bantulah kaum eldia menggunakan colossal agar dapat bekerja sama dengan baik. Kemudian lakukan testing dengan 6000 request dan 200 request/second. (7)

- buat lah script untuk **Collosal (Load Balancer)** bernama `collosal.sh`
    ```
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

    # Restart layanan Nginx agar konfigurasi baru berlaku
    service nginx restart
    ```

- Tes dengan coba jalankan `ab -n 6000 -c 200 http://192.239.3.2:1111/` (ip dari collosal) dan port 1111 untuk **Round Robin**

    ![image](https://github.com/user-attachments/assets/f3497388-87d9-47fe-a301-fc6a5197339f)


#### Nomor 8

> Karena Erwin meminta “laporan kerja Armin”, maka dari itu buatlah analisis hasil testing dengan 1000 request dan 75 request/second untuk masing-masing algoritma Load Balancer dengan ketentuan sebagai berikut:
> a. Nama Algoritma Load Balancer
> b. Report hasil testing pada Apache Benchmark
> c. Grafik request per second untuk masing masing algoritma. 
> d. Analisis (8)

- Tambahkan konfig berikut pada script `collosal.sh`
    ```
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
    ```

- Tes bisa dilakukan dengan ketik `ab -n 1000 -c 75 http://192.239.3.2:1111/` port dicoba antara rentang 1111-1115, berikut adalah contoh nya
    ![image](https://github.com/user-attachments/assets/665a5b47-94dd-4f6f-ae3e-7f1a0651d6d3)

- Untuk **Dokumen Laporan Benchmark** bisa dilihat pada pdf di repo.

#### Nomor 9
> Dengan menggunakan algoritma Least-Connection, lakukan testing dengan menggunakan 3 worker, 2 worker, dan 1 worker sebanyak 1000 request dengan 10 request/second, kemudian tambahkan grafiknya pada “laporan kerja Armin”.

- Manipulasi worker dengan cara comment ke worker yang tidak berkerja seperti pada gambar:

    ![image](https://github.com/user-attachments/assets/2d7efac2-1ab8-449a-b492-826bbb994ebc)

- Least Connnection dengan 1 worker:

    ![image](https://github.com/user-attachments/assets/951d91a6-cd53-49a6-b41f-6b86bca1c962)

- Least Connnection dengan 1 worker:

    ![image](https://github.com/user-attachments/assets/d93dbc4c-0788-49d5-a4e9-0c4daeea6319)

- Least Connnection dengan 1 worker:

    ![image](https://github.com/user-attachments/assets/da1d05cc-36c9-49dd-890f-b7004f539302)

- Grafik perbandingan

    ![image](https://github.com/user-attachments/assets/0ed13a63-c798-48b9-a77f-7b0b85192b76)


#### Nomor 10
> Selanjutnya coba tambahkan keamanan dengan konfigurasi autentikasi di Colossal dengan dengan kombinasi username: “arminannie” dan password: “jrkmyyy”, dengan yyy merupakan kode kelompok. Terakhir simpan file “htpasswd” nya di /etc/nginx/supersecret/

- Membuat direktori dan membuat file htpasswd
    ```
    # Membuat direktori untuk menyimpan file htpasswd
    mkdir -p /etc/nginx/supersecret

    # Membuat file htpasswd dengan username arminannie dan password jrkmit25
    htpasswd -cb /etc/nginx/supersecret/htpasswd arminannie jrkmit12
    ```
- Menambahkan line berikut untuk setiap algoritma
    ```
        location / {
            proxy_pass http://round-robin; # ganti setiap algoritma
            auth_basic "Restricted Content";
            auth_basic_user_file /etc/nginx/supersecret/htpasswd;
        }
    ```
- Tes dengan jalankan lagi `lynx http://192.239.3.2:1111/` maka akan di arah untuk enter username dan password terlebih dahulu

    ![image](https://github.com/user-attachments/assets/9a0b3670-9581-440b-8e52-5c10b49b0d62)

    ![image](https://github.com/user-attachments/assets/4490d3cf-79a6-4242-894b-4bce78589df1)

    ![image](https://github.com/user-attachments/assets/5b826e6a-b19d-40d9-ad43-6bcb85db0cd7)

