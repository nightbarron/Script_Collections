#!/bin/bash
hours=`date | awk '{print $8}' | cut -d':' -f1`
minutes=`date | awk '{print $8}' | cut -d':' -f2`
number=${hours}${minutes}
numberx=`expr $number - 0`


# NOTE: 429: 4h 29p
if [[ $((numberx)) -gt 000 && $((numberx)) -lt 010 ]];
then
    /usr/sbin/ipset -F BLACKLIST_SrcDstportDst
    /usr/sbin/ipset -F bad_client
    /usr/sbin/ipset -F botnet_counter
    /usr/sbin/ipset -F botnets
    /usr/sbin/ipset -F unreliable_client
fi