#!/bin/bash
#Pluto Control Panel installation file for Ubuntu

#generate password
genpass=strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'
myip=dig +short myip.opendns.com @resolver1.opendns.com

dist_codename="$(lsb_release -c|awk '{print $2}')"
dist_release="$(lsb_release -r|awk '{print $2}')"

if [ "$dist_release" = '16.04' ]; then
    packages="awstats bc bsdmainutils bsdutils cron curl dnsutils e2fslibs e2fsprogs expect fail2ban flex ftp git idn imagemagick lsof mc mysql-client mysql-common nano ntpdate php php-cgi php-common php-curl php-fpm php-mysql php-pgsql phpmyadmin quota rrdtool rssh sudo vsftpd whois zip"
else
    packages="awstats bc bsdmainutils bsdutils cron curl dnsutils e2fslibs e2fsprogs expect fail2ban flex ftp git idn imagemagick lsof mc mysql-client mysql-common nano ntpdate php5 php5-cgi php5-common php5-curl php5-fpm php5-mysql php5-pgsql phpmyadmin quota rrdtool rssh sudo vsftpd whois zip"
fi

#download Caddy Server
sudo mkdir /usr/bin/caddy && cd /usr/bin/caddy && sudo wget https://caddyserver.com/download/build?os=linux&arch=amd64&features=awslambda%2Ccors%2Cexpires%2Cfilemanager%2Cgit%2Chugo%2Cipfilter%2Cjsonp%2Cjwt%2Clocale%2Cmailout%2Cminify%2Cmultipass%2Cprometheus%2Cratelimit%2Crealip%2Csearch%2Cupload%2Ccloudflare%2Cdigitalocean%2Cdnsimple%2Cdyn%2Cgandi%2Cgooglecloud%2Clinode%2Cnamecheap%2Crfc2136%2Croute53%2Cvultr
sudo tar xf caddy_linux_amd64_custom.tar.gz

#update
sudo apt-get -y update
sudo apt-get -y upgrade

#configure mysql password
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password your_password'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password your_password'

#install packages
sudo apt-get -y install $packages
if [ $? -eq 0 ]; then
    echo "apt-get install succeded"
else
    echo "[ERROR] apt-get install failed"
fi

mkdir /var/pluto
mkdir /etc/pluto

cp config/Caddyfile /etc/pluto/Caddyfile
cp -R panel /var/pluto/panel

#mysqld --initialize-insecure

#mysql helpers to be used later on
#credit to @kenorb - http://stackoverflow.com/a/36190905

# Create user in MySQL/MariaDB.
mysql-create-user() {
  [ -z "$2" ] && { echo "Usage: mysql-create-user (user) (password)"; return; }
  mysql -ve "CREATE USER '$1'@'localhost' IDENTIFIED BY '$2'"
}

# Delete user from MySQL/MariaDB
mysql-drop-user() {
  [ -z "$1" ] && { echo "Usage: mysql-drop-user (user)"; return; }
  mysql -ve "DROP USER '$1'@'localhost';"
}

# Create new database in MySQL/MariaDB.
mysql-create-db() {
  [ -z "$1" ] && { echo "Usage: mysql-create-db (db_name)"; return; }
  mysql -ve "CREATE DATABASE IF NOT EXISTS $1"
}

# Drop database in MySQL/MariaDB.
mysql-drop-db() {
  [ -z "$1" ] && { echo "Usage: mysql-drop-db (db_name)"; return; }
  mysql -ve "DROP DATABASE IF EXISTS $1"
}

# Grant all permissions for user for given database.
mysql-grant-db() {
  [ -z "$2" ] && { echo "Usage: mysql-grand-db (user) (database)"; return; }
  mysql -ve "GRANT ALL ON $2.* TO '$1'@'localhost'"
  mysql -ve "FLUSH PRIVILEGES"
}

# Show current user permissions.
mysql-show-grants() {
  [ -z "$1" ] && { echo "Usage: mysql-show-grants (user)"; return; }
  mysql -ve "SHOW GRANTS FOR '$1'@'localhost'"
}



#secure mysql
#connect
mysqladmin -u root password $genpass

#set up parameters for future connections to mysql from root user
touch /root/.my.cnf
chmod 600 /root/.my.cnf
echo -e "[client]\npassword='$genpass'\n" > /root/.my.cnf

#drop test databases
mysql -e "DROP DATABASE test" >/dev/null 2>&1
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
mysql -e "DELETE FROM mysql.user WHERE user='' or password='';"
mysql -e "FLUSH PRIVILEGES"

#create new user
mysql-create-user admin $genpass
mysql-create-db pluto
mysql-grant-db admin pluto

daemon --name="caddy" --output=/var/log/caddy.log --config /etc/pluto/Caddyfile
sudo update-rc.d caddy remove
sudo update-rc.d caddy defaults

#print success message
echo "DONE"
echo 'IP:$myip:7777'
echo "USERNAME: admin"
echo 'PASSWORD: $genpass'