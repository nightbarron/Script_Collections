#!/bin/bash
ipset -F BLACKLIST_SrcDstportDst
ipset -F botnets
ipset -F bad_client
ipset -F unreliable_client

## PRO
#!/bin/bash
declare -a setName
setName+=("BLACKLIST_SrcDstportDst" "unreliable_client" "bad_client" "botnets" )

for i in ${!setName[@]}; do
    #echo ${setName[$i]}
    ipset -F ${setName[$i]}
done