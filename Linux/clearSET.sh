#!/bin/bash
declare -a setName
setName+=("BLACKLIST_SrcDstportDst" "unreliable_client" "bad_client" "botnets" )

for i in ${!setName[@]}; do
    #echo ${setName[$i]}
    ipset -F ${setName[$i]}
done