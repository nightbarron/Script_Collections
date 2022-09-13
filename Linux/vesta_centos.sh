#!/bin/bash
installBaseVesta(){
    curl -O http://vestacp.com/pub/vst-install.sh
    bash vst-install.sh --nginx yes --apache yes --phpfpm no --named yes --remi no --vsftpd yes --proftpd no --iptables yes --fail2ban no --quota no --exim yes --dovecot yes --spamassassin no --clamav no --softaculous yes --mysql yes --postgresql no --hostname $1 --email $2 --password $3
    rm -rf vst-install.sh
}

installRemiPHP(){
    yum install epel-release yum-utils -y
    yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
    yum-config-manager --enable remi-php${1}
    yum install php php-common php-opcache php-mcrypt php-xml php-xmlrpc php-cli php-gd php-curl php-mysqlnd php-mssql php-json php-mbstring -y
    service httpd reload
}

main(){
    echo -n "Your hostname: "
    read hostname
    echo -n "Your email: "
    read email
    echo -n "Your password: "
    read pass
    echo -n "PHP version (ex: 56, 70, 71, 72, 73, 74, 80): "
    read phpvs

    installBaseVesta $hostname $email $pass
    installRemiPHP $phpvs 
}

main