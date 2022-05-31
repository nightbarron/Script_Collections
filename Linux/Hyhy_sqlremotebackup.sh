#!/bin/bash
PATH_BACKUP='/home/databases_backup'
DATE_BACKUP=$(date +%y-%m-%d)

ssh 14.225.253.241 'mysqldump sangkien' > ${PATH_BACKUP}/sangkien-${DATE_BACKUP}.sql
find $PATH_BACKUP -type f -name "*.sql" -mtime +1 -delete