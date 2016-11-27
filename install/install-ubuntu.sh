#!/bin/bash
#Pluto Control Panel installation file for Ubuntu

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

#install packages
sudo apt-get -y install $packages
if [ $? -eq 0 ]; then
    echo "apt-get install succeded"
else
    echo "[ERROR] apt-get install failed"
fi


