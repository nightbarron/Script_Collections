#/bin/bash

find /home/admin/user_backups/* -type d -ctime +3 -exec rm -rf {} \;