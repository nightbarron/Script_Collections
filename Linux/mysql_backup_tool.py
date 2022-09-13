# This python code designed for CRONTAB, please change at (*) for yours!!!

#########################################################################################
#                                                                                       #
#   #AUTHOR:        NIGHTBARRON                                                         #
#   #DATE:          27/04/2021                                                          #
#   #For remoted backup, just change the MYSQL_HOST                                     #
#   #CRON:                                                                              #
#       # example cron for daily db backup @ 9:15 am                                    #
#       # min  hr mday month wday user-name command                                     #
#       # 15   9  *    *     *    root      python /path_to_file/mysql_backup.py        #
#                                                                                       #
#   #Default BACKUP DIRECTORY: ~/sql_backup/<YYmmDD>/<dbname>.sql.gz                    #
#                                                                                       #
#   #RESTORE FROM BACKUP                                                                #
#       # CREATE DATABASE as THE SAME as LOST!!                                         #
#       #$ gunzip < [backupfile.sql.gz] | mysql -u [uname] -p[pass] [dbname]            #
#                                                                                       #
#########################################################################################

# LIBRARIES
import os
import datetime
import MySQLdb

# CHANGE HERE !!!

# GLOBAL VARIABLES
MYSQL_USER = 'root'             # NOT RECOMMEND CHANGED
MYSQL_PASS = '123456a@'         # (*)
MYSQL_HOST = '192.168.75.75'    # (*)

IGNORE_DB = "(^mysql|^sys$|_schema$)"
DATE_BACKUP = (datetime.datetime.now()).strftime("%Y%m%d")
BACKUP_DIR = os.path.expanduser("~") + "/sql_backup/" + DATE_BACKUP

# Funtions

def motd():
    print('!!!_Welcome to MySQL BACKUP tool_!!!!')
    print('@Author: Night Barron')
    print('## NOTE: Default BACKUP DIRECTORY: ' + BACKUP_DIR + '/<dbname>.sql.gz')
    print('\nMySQL SERVER:', MYSQL_HOST, "\n")

def getDatabaseList():
    # Connect to database and get data
    serv = MySQLdb.connect(host = MYSQL_HOST, user = MYSQL_USER, passwd = MYSQL_PASS)
    cur = serv.cursor()
    sqlStatement = "SHOW DATABASES WHERE `Database` NOT REGEXP \"" + IGNORE_DB + "\""
    cur.execute(sqlStatement)
    result = cur.fetchall()
    cur.close()
    serv.close()
    return result

def backupDatabases(databasesRaw):
    count = 0
    for database in databasesRaw:
        databaseName = database[0]
        count += 1
        print("...backing up", count, "of", len(databasesRaw), "databases:", databaseName)
        shellBackupStatement = "mysqldump -u" + MYSQL_USER + " -h " + MYSQL_HOST \
            + " -p" + MYSQL_PASS + " " + databaseName + " 2>&1 | grep -v \"Using a password on the command\" | gzip -9 > " \
            + BACKUP_DIR + "/" + databaseName + ".sql.gz"
        os.system(shellBackupStatement)


def main():

    motd()
    # MAKE BACKUP DIR
    os.system("mkdir -p " + BACKUP_DIR)

    databasesRaw = getDatabaseList()

    backupDatabases(databasesRaw)
    print('\nAll databases backed up!!!')

main()

