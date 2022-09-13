#!/bin/bash
# For Vestacp ONLY
echo "" > domain.txt
for domain in `v-list-users | grep -vE "USER|---" | awk '{print $1}'`; do
        search_dir=`ls /home/${domain}/web/`
        #list=""
        for entry in $search_dir; do
                #echo "checking: $entry"
                #echo
                list=`host $entry | awk '{print $4}' | head -n 1`
                #echo "IP: $list"
                if [[ $list != 171.244.18.37 ]];
                then
                                echo  "[+] $entry | $list"
                                echo $entry >> domain.txt
                fi

        done
done