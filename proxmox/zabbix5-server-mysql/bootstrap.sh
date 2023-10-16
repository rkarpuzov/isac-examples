 
#!/bin/bash

apt install -y wget

wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+focal_all.deb
dpkg -i zabbix-release_5.0-1+focal_all.deb
apt update 
apt upgrade -y
apt install -y mariadb-server

# Install PHP version 7.4 manually due dependancy of Web server, default Apache2. We want to install lightweight Nginx
VERSION=7.4
apt-get -y install php$VERSION-fpm php$VERSION-curl php$VERSION-mbstring php$VERSION-readline php$VERSION-json php$VERSION-opcache php$VERSION-mysql php$VERSION-bcmath php$VERSION-soap php$VERSION-xml php$VERSION-zip 

apt install -y zabbix-server-mysql zabbix-frontend-php php$VERSION-pgsql zabbix-nginx-conf zabbix-agent

sleep 2

mysql <<EOF
create database zabbix character set utf8 collate utf8_bin;
create user zabbix@localhost identified by 'password';
grant all privileges on zabbix.* to zabbix@localhost;
set global log_bin_trust_function_creators = 1;
EOF

sleep 2


zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql zabbix

mysql <<EOF
set global log_bin_trust_function_creators = 0;
EOF

# The DBPassword is the same one as provided as the ending of "create user" command above
sed -i s/#\ DBPassword=/DBPassword=password/g     /etc/zabbix/zabbix_server.conf
sed -i s/#\ DBHost=localhost/DBHost=localhost/g  /etc/zabbix/zabbix_server.conf


apt install -y nginx php7.4-fpm

# We want to see the Zabbix page instead ot the default one
rm /etc/nginx/sites-enabled/default

sed -i s/^#//g /etc/zabbix/nginx.conf
sed -i s/example.com/zabbix.roots.bg/g /etc/zabbix/nginx.conf
sed -i s/^\;//g /etc/zabbix/php-fpm.conf
sed -i s/Riga/Sofia/g /etc/zabbix/php-fpm.conf

systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm
systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm 

