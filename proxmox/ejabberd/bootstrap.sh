#!/bin/bash
# Just in case:
cp -a /etc/ejabberd/ejabberd.yml /etc/ejabberd/ejabberd.yml-old

# Update your OS:
apt update
apt upgrade -y
# Bugfix, reboot reguired:
apt purge apparmor

apt install -y ejabberd miniupnpc binutils postgresql-client

# Download yq util to manage YAML config files
cd /tmp
export VERSION=v4.30.4
export BINARY=yq_linux_amd64
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - |  tar xz && mv ${BINARY}  yq
strip yq
#### Password section:
echo examplepass > /root/.pgpass
chmod 0600 /root/.pgpass
export hostnamecfg='public.example.org'
export pgsql_connect='{"sql_type": "pgsql", "sql_server":"10.10.10.101", "sql_database":"ejabberd", "sql_username":"ejabberd", "sql_password":"examplepass", "auth_method":"[sql]"}'
export custom_headers='{"Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "OPTIONS, HEAD, GET, PUT", "Access-Control-Allow-Headers": "Authorization", "Access-Control-Allow-Credentials": "true"}'
export mod_http_upload='{"name": "HTTP File Upload", "access": "local", "max_size": "104857600 # 100 MiB.", "file_mode": "0640", "dir_mode": "2750", "docroot": "/var/lib/ejabberd/upload/@HOST@", "put_url": "https://@HOST@:5443/upload", "thumbnail": "false"}'
export mod_disco='{"modules": "all", "name": "abuse-addresses", "urls": "[\"mailto:abusecontact@yourserver.com\"]"}'
./yq -i '.hosts[0] = "example.tld"' /etc/ejabberd/ejabberd.yml
./yq -i 'with(.host_config."example.tld"; . |= env(pgsql_connect) | ... style="")' /etc/ejabberd/ejabberd.yml
# Known bug: auth_method must have only squares [] without single quotes '' remove them by hand
./yq -i 'with(.modules.mod_disco.server_info[0]; . |= env(mod_disco) | ... style="")' /etc/ejabberd/ejabberd.yml
# Known bug: the same problem with square brackets around mailto address
./yq -i '.acl.admin.user[0] = "admin@example.tld"' /etc/ejabberd/ejabberd.yml
./yq -i '.modules.mod_register.registration_watchers[0] = "admin@example.tld"' /etc/ejabberd/ejabberd.yml
./yq -i '.modules.mod_register.captcha_protected = true' /etc/ejabberd/ejabberd.yml
./yq -i '.captcha_cmd = "/usr/share/ejabberd/captcha.sh"' /etc/ejabberd/ejabberd.yml
./yq -i '.listen[3].request_handlers./upload = "mod_http_upload"' /etc/ejabberd/ejabberd.yml
./yq -i '.listen[3].request_handlers./register = "mod_register_web"' /etc/ejabberd/ejabberd.yml
./yq -i '.listen[3].request_handlers./captcha = "ejabberd_captcha"' /etc/ejabberd/ejabberd.yml
./yq -i 'with(.listen[3].custom_headers; . |= env(custom_headers) | ... style="")' /etc/ejabberd/ejabberd.yml
./yq -i '.modules.mod_pubsub.hosts[0] = "news.@HOST@"' /etc/ejabberd/ejabberd.yml
./yq -i '.modules.mod_pubsub.hosts[1] = "comics.@HOST@"' /etc/ejabberd/ejabberd.yml
./yq -i '.modules.mod_pubsub.hosts[2] = "nsfw.@HOST@"' /etc/ejabberd/ejabberd.yml
./yq -i '.modules.mod_pubsub.hosts[3] = "lifestyle.@HOST@"' /etc/ejabberd/ejabberd.yml
./yq -i '.modules.mod_pubsub.hosts[3] = "blog.@HOST@"' /etc/ejabberd/ejabberd.yml
./yq -i '.default_db = "sql"' /etc/ejabberd/ejabberd.yml
./yq -i '.modules.mod_mam.default = "always"' /etc/ejabberd/ejabberd.yml
./yq -i '.modules.mod_proxy65 = {}' /etc/ejabberd/ejabberd.yml
./yq -i 'with(.modules.mod_disco.server_info; . |= env(mod_disco) | ... style="")' /etc/ejabberd/ejabberd.yml
./yq -i 'with(.modules.mod_http_upload; . |= env(mod_http_upload) | ... style="")' /etc/ejabberd/ejabberd.yml 
# Known bug: max_size must be integer, fix it by hand TODO fix
chown ejabberd. /etc/ejabberd/ejabberd.yml  # bug, yq changes the rights to root

psql -h 10.10.10.101 -U ejabberd -w ejabberd < /usr/share/ejabberd/sql/pg.sql

#apt -y install postgresql-client-14

crontab -l > /tmp/crontab.tmp
echo "30 1 1 * * cat /etc/letsencrypt/live/example.tld/privkey.pem /etc/letsencrypt/live/example.tld/fullchain.pem > /etc/ejabberd/ejabberd.pem" >> /tmp/crontab.tmp
echo "33 1 1 * * systemctl restart ejabberd.service" >> /tmp/crontab.tmp
crontab /tmp/crontab.tmp
