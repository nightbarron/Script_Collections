#!/bin/bash

percent=`df -Th | grep "/tmp$" | awk '{print $6}'`
percent=${percent%\%}
echo ${percent}
die=90

if [ ${percent} -gt ${die} ]
then 
    [ -d /root/tmpcore ] || mkdir /root/tmpcore
    #echo "Die"
    cp -r /tmp/core.* /root/tmpcore/. 
fi