#!/bin/bash
# Author: Night Barron
# Date: 22-08-22

DIR='/var/log/nginx'
DATE_BACKUP=$(date +%y%m%d)
KEEP_BACKUPS_FOR=3 # DAYS

function main(){
    files=`ls -1 $DIR`
    for file in $files
    do
        #echo $file
        cp ${DIR}/${file} ${DIR}/${file}_${DATE_BACKUP}
        echo "" > ${DIR}/${file}
    done 
    find ${DIR} -type f -mtime +${KEEP_BACKUPS_FOR} -delete 
}

main