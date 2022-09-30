#!/bin/sh

# HELP
# using: install_SSL.sh <domain>
getDomainBackground(){
    echo ">> Finding user:"
    cd /home/*/web/${DOMAIN}/
    USER=`pwd | /bin/cut -d '/' -f3` 
    echo " [*] User: ${USER}"
    PATH='/home/'${USER}'/conf/web/'
    echo ">> Finding IP:"
    IP=`/bin/ls /etc/nginx/conf.d/ | /bin/egrep "^([0-9]{1,3}\.){3}[0-9]*" -o`
    IP=${IP[0]}
    echo " [*] IP: ${IP}"
    echo
}

putConfigToServer() {
    echo
    echo "Config server: "
    printf 'server {
    listen      %s:443 ssl;
    server_name %s www.%s;
    ssl_certificate      /home/%s/conf/web/ssl.%s.pem;
    ssl_certificate_key  /home/%s/conf/web/ssl.%s.key;
    error_log  /var/log/httpd/domains/%s.error.log error;

    location / {
        proxy_pass      https://%s:8443;
        location ~* ^.+\.(jpeg|jpg|png|gif|bmp|ico|svg|tif|tiff|css|js|htm|html|ttf|otf|webp|woff|txt|csv|rtf|doc|docx|xls|xlsx|ppt|pptx|odf|odp|ods|odt|pdf|psd|ai|eot|eps|ps|zip|tar|tgz|gz|rar|bz2|7z|aac|m4a|mp3|mp4|ogg|wav|wma|3gp|avi|flv|m4v|mkv|mov|mpeg|mpg|wmv|exe|iso|dmg|swf)$ {
            root           /home/%s/web/%s/public_html;
            access_log     /var/log/httpd/domains/%s.log combined;
            access_log     /var/log/httpd/domains/%s.bytes bytes;
            expires        max;
            try_files      $uri @fallback;
        }
    }

    location /error/ {
        alias   /home/%s/web/%s/document_errors/;
    }

    location @fallback {
        proxy_pass      https://%s:8443;
    }

    location ~ /\.ht    {return 404;}
    location ~ /\.svn/  {return 404;}
    location ~ /\.git/  {return 404;}
    location ~ /\.hg/   {return 404;}
    location ~ /\.bzr/  {return 404;}

    include /home/%s/conf/web/snginx.%s.conf*; 
}' ${IP} ${DOMAIN} ${DOMAIN} ${USER} ${DOMAIN} ${USER} ${DOMAIN} ${DOMAIN} ${IP} ${USER} ${DOMAIN} ${DOMAIN} ${DOMAIN} ${USER} ${DOMAIN} ${IP} ${USER} ${DOMAIN} > ${PATH}/${DOMAIN}.nginx.ssl.conf

    echo "  [*] CREATED: ${PATH}/${DOMAIN}.nginx.ssl.conf"
    printf '<VirtualHost %s:8443>

    ServerName %s
    
    ServerAlias info@%s
    DocumentRoot /home/%s/web/%s/public_html
    ScriptAlias /cgi-bin/ /home/%s/web/%s/cgi-bin/
    Alias /vstats/ /home/%s/web/%s/stats/
    Alias /error/ /home/%s/web/%s/document_errors/
    #SuexecUserGroup %s %s
    CustomLog /var/log/httpd/domains/%s.bytes bytes
    CustomLog /var/log/httpd/domains/%s.log combined
    ErrorLog /var/log/httpd/domains/%s.error.log
    <Directory /home/%s/web/%s/public_html>
        AllowOverride All
        SSLRequireSSL
        Options +Includes -Indexes +ExecCGI
        php_admin_value open_basedir /home/%s/web/%s/public_html:/home/%s/tmp
        php_admin_value upload_tmp_dir /home/%s/tmp
        php_admin_value session.save_path /home/%s/tmp
    </Directory>
    <Directory /home/%s/web/%s/stats>
        AllowOverride All
    </Directory>
    SSLEngine on
    SSLVerifyClient none
    SSLCertificateFile /home/%s/conf/web/ssl.%s.crt
    SSLCertificateKeyFile /home/%s/conf/web/ssl.%s.key
    #SSLCertificateChainFile /home/%s/conf/web/ssl.%s.ca

    <IfModule mod_ruid2.c>
        RMode config
        RUidGid %s %s
        RGroups apache
    </IfModule>
    <IfModule itk.c>
        AssignUserID %s %s
    </IfModule>

    #IncludeOptional /home/%s/conf/web/shttpd.%s.conf*

</VirtualHost>' ${IP} ${DOMAIN} ${DOMAIN} ${USER} ${DOMAIN} ${USER} ${DOMAIN} ${USER} ${DOMAIN} ${USER} ${DOMAIN} ${USER} ${USER} ${DOMAIN} ${DOMAIN} ${DOMAIN} ${USER} ${DOMAIN} ${USER} ${DOMAIN} ${USER} ${USER} ${USER} ${USER} ${DOMAIN} ${USER} ${DOMAIN} ${USER} ${DOMAIN} ${USER} ${DOMAIN} ${USER} ${USER} ${USER} ${USER} ${USER} ${DOMAIN} > ${PATH}/${DOMAIN}.httpd.ssl.conf
    echo "  [*] CREATED: ${PATH}/${DOMAIN}.httpd.ssl.conf"
    echo "include /home/${USER}/conf/web/${DOMAIN}.nginx.ssl.conf;" >> /etc/nginx/conf.d/vesta.conf
    echo "  [*] ADDED ${DOMAIN}.nginx.ssl.conf to /etc/nginx/conf.d/vesta.conf"
    echo "Include /home/${USER}/conf/web/${DOMAIN}.httpd.ssl.conf" >> /etc/httpd/conf.d/vesta.conf
    echo "  [*] ADDED ${DOMAIN}.httpd.ssl.conf to /etc/httpd/conf.d/vesta.conf"
}

createSSLFile() {
    /bin/touch /home/${USER}/conf/web/ssl.${DOMAIN}.key
    /bin/touch /home/${USER}/conf/web/ssl.${DOMAIN}.crt
    /bin/touch /home/${USER}/conf/web/ssl.${DOMAIN}.ca
    /bin/touch /home/${USER}/conf/web/ssl.${DOMAIN}.pem
}

printNextStep() {
    echo
    echo ">> That's all my task!"
    echo "Please put your cert here and reload config:"
    echo "  [*] CRT: /home/${USER}/conf/web/ssl.${DOMAIN}.crt"
    echo "  [*] KEY: /home/${USER}/conf/web/ssl.${DOMAIN}.key"
    echo "  [*] PEM: /home/${USER}/conf/web/ssl.${DOMAIN}.pem"
    echo "  [*] CA: /home/${USER}/conf/web/ssl.${DOMAIN}.ca"
}


main() {
    echo "SETTING UP SSL STARTING..."
    echo
    getDomainBackground
    putConfigToServer
    createSSLFile
    printNextStep
    echo "EXIT!!!"
}



# Execute From Here
DOMAIN=$1
USER='admin'
PATH=''
IP=''
main

# InstallSSL.sh <domain>
