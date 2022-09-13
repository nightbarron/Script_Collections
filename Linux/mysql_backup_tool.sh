#!/bin/bash

# FOR CRONTAB, FOLLOWING (*) x2.

#########################################################################################
#                                                                                       #
#   #AUTHOR:        NIGHTBARRON                                                         #
#   #DATE:          27/04/2021                                                          #
#   #CRON:                                                                              #
#       # example cron for daily db backup @ 9:15 am                                    #
#       # min  hr mday month wday user-name command                                     #
#       # 15   9  *    *     *    root      /path_to_file/mysql_backup.sh               #
#                                                                                       #
#   #Default BACKUP DIRECTORY: ~/sql_backup/<YYmmDD>/<dbname>.sql.gz                    #
#                                                                                       #
#   #RESTORE FROM BACKUP                                                                #
#       # CREATE DATABASE as THE SAME as LOST!!                                         #
#       #$ gunzip < [backupfile.sql.gz] | mysql -u [uname] -p[pass] [dbname]            #
#                                                                                       #
#########################################################################################

# Global Variables

MYSQL_USER='root'

# (*) EDIT PASSWORD HERE FOR CRONTAB WORKING!!!
MYSQL_PASSWD='123456a@'

IGNORE_DB="(^mysql|^sys$|_schema$)"
DATE_BACKUP=$(date +%y%m%d)
OLD_BACKUP=$(date +%y%m%d --date='-3 day')
BACKUP_DIR=$HOME"/sql_backup/"$DATE_BACKUP
KEEP_BACKUPS_FOR=3 # DAYS
DELETED_DIR=$HOME"/sql_backup/"$OLD_BACKUP

# Functions

rootPasswd() {
    # Read user passwd for ROOT SQL
    echo -n 'ROOT MySQL Password:' 
    read -s MYSQL_PASSWD
}

mySqlLogin() {
    local mySqlLoginStatement="-u $MYSQL_USER" 

    if [ -n "$MYSQL_PASSWD" ]; then
        local mySqlLoginStatement+=" -p$MYSQL_PASSWD" 
    fi
    echo $mySqlLoginStatement
}

motd() {
    echo '!!!_Welcome to MySQL BACKUP tool_!!!!'
    echo '@Author: Night Barron'
    echo '## NOTE: Default BACKUP DIRECTORY: '$BACKUP_DIR'/<dbname>.sql.gz'
    echo
}

deleteOldBackup() {
    echo "Deleting $OLD_BACKUP/*.sql.gz older than $KEEP_BACKUPS_FOR days"
    rm -rf $OLD_BACKUP
}

databaseList() {
    local sqlStatement="SHOW DATABASES WHERE \`Database\` NOT REGEXP '$IGNORE_DB'"
    echo $(mysql $(mySqlLogin) -e "$sqlStatement" 2>&1 | grep -v "Using a password on the command" | awk -F " " '{if (NR!=1) print $1}')
}

backUpDatabase(){
    backUpFile="$BACKUP_DIR/$database.sql.gz" 
    outPut+="$database => $backUpFile\n"
    echo "...backing up $count of $total databases: $database"
    $(mysqldump $(mySqlLogin) $database 2>&1 | grep -v "Using a password on the command" | gzip -9 > $backUpFile)
}

backUpDatabases(){
    local databases=$(databaseList)
    local total=$(echo $databases | wc -w | xargs)
    local outPut=""
    local count=1

    echo 
    echo
    echo 'Backing up:'

    for database in $databases; do
        backUpDatabase
        local count=$((count+1))
    done

    echo
    echo "BACKUP STORAGE: "
    echo -ne $outPut | grep -Ev "^$" | column -t
}

mainEntry(){
    motd
    deleteOldBackup
    # Make BACKUP FOLDER 
    mkdir -p $BACKUP_DIR
    # Get root MySQL Password

    # (*) DISABLED LINE BELOW FOR CRONTAB
    rootPasswd

    # Create Backup
    backUpDatabases
}

# Call HERE/ Try catch for ERRORS case if happen!!!
{
    mainEntry
    echo "All databases backed up!"
} || {
    echo "Backing up fail! CHECK YOUR PERMISSIONS!!!"
} 
