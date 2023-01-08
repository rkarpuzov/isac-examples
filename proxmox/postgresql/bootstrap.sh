#!/bin/bash
# check your postgresql version. This is valid path for Ubuntu 22.04 LTS

apt update
apt upgrade -y
apt install -y postgresql
echo host all movim 10.10.10.100/32 trust >> /etc/postgresql/14/main/pg_hba.conf
echo host all movim 0.0.0.0/0 md5 >> /etc/postgresql/14/main/pg_hba.conf
echo host all movim ::0/0 md5 >> /etc/postgresql/14/main/pg_hba.conf
echo listen_addresses = \'*\' >> /etc/postgresql/14/main/postgresql.conf
