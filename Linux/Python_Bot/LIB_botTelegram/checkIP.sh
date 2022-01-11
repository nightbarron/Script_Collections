#!/bin/bash
# REQUIRE jq
chat_id="-567723202"        # Default
chat_id=$1
domainName=""
token="1741302312:AAHUJEV2WsKzCu8wBF6Uq9zwBPL7F724wYoo"
IP_check=$2
option_check=$3

#echo "1. Check for Windows"
#echo "2. Check for Linux"
#read -p 'Enter your option: ' option_check
curl -X POST "https://api.telegram.org/bot"$token"/sendMessage" -d "chat_id="${chat_id}"&text=Please wait for 10s!"
#echo "==================================================================================="
#echo "===== Checking....."
case "$option_check" in 
"W")
    #echo "W"
    request_id=`curl -H "Accept: application/json" \
"https://check-host.net/check-tcp?host="${IP_check}":3389&max_nodes=20" | jq ".request_id" | sed -e 's/^"//' -e 's/"$//'`
    
    sleep 10
    
    report=`curl -H "Accept: application/json" \
https://check-host.net/check-result/${request_id} | grep -ow 'error' | wc -l`

    ;;
"L")
    #echo "L"
    request_id=`curl -H "Accept: application/json" \
"https://check-host.net/check-ping?host="${IP_check}"&max_nodes=20" | jq ".request_id" | sed -e 's/^"//' -e 's/"$//'`
    
    sleep 10
    
    report=`curl -H "Accept: application/json" \
https://check-host.net/check-result/${request_id} | grep -ow 'null' | wc -l`

    ;;
*)
    #echo ${option_check}
    request_id=`curl -H "Accept: application/json" \
"https://check-host.net/check-tcp?host="${IP_check}":"${option_check}"&max_nodes=20" | jq ".request_id" | sed -e 's/^"//' -e 's/"$//'`
    
    sleep 10
    
    report=`curl -H "Accept: application/json" \
https://check-host.net/check-result/${request_id} | grep -ow 'error' | wc -l`
    ;;
esac

#echo "==================================================================================="

#echo "Link report: https://check-host.net/check-report/"${request_id}

if [[ $report > 11 ]];
then 
    #echo "==============⚠️IP bị chặn quốc tế ⚠️=============="
    curl -X POST "https://api.telegram.org/bot"$token"/sendMessage" -d "chat_id="${chat_id}"&text=RESULT: 🚫 ${IP_check} is blocked International 🚫!
Link: https://check-host.net/check-report/${request_id}"
else 
    #echo "==============✅IP không bị chặn quốc tế ✅=============="
    curl -X POST "https://api.telegram.org/bot"$token"/sendMessage" -d "chat_id="${chat_id}"&text=RESULT: ✅ ${IP_check} is accepted International ✅!
Link: https://check-host.net/check-report/${request_id}"
fi