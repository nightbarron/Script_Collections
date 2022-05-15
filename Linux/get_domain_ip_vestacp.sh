#!/bin/bash
search_dir=`ls /home/$1/web/`
#list=""
for entry in $search_dir; do
        echo "checking: $entry"
	echo
        list=`host $entry | awk '{print $4}' | head -n 1`
        #echo "IP: $list"
        if [[ $list != 171.244.18.37 ]];
               then
                       echo  "[+] $entry"
			echo $entry >> domain.txt
               fi

done