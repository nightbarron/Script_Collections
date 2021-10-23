 #!/bin/bash
chat_id="-567723202"        # Default
domainName=""
token="1741302312:AAEYs97TnxuuKKvq5h94IARA1haWyNAG21E"

# pip install sslchecker

checkDomain() {
    ip=`host ${domainName} | awk '{print $4}' | head -n 1`
    record=`host -a ${domainName} 8.8.8.8 | grep ^${domainName} | grep "NS\|A\|SOA\|HINFO" | sort -k 4 | awk '{print $1 " " $4 "\t" $5}'`
    flag=`echo $record | awk '{print $2}'`
    hinfo="HINFO"
    if [ ${mode} = 'O' ]; then
        if [ ${#ip} -lt 8 ]; then
            curl -X POST "https://api.telegram.org/bot"$token"/sendMessage" -d "chat_id="${chat_id}"&text=RESULT: ${domainName} did not resolve IP!"
        else
            #echo ${flag}
            if [ ${flag} = "HINFO" ]; then
                curl -X POST "https://api.telegram.org/bot"$token"/sendMessage" -d "chat_id="${chat_id}"&text=RESULT: ${domainName} point to CloudFlare!"
            else
                curl -X POST "https://api.telegram.org/bot"$token"/sendMessage" -d "chat_id="${chat_id}"&text=RESULT: ${domainName} point to ${ip}"
            fi
        fi
    else 
        curl -X POST "https://api.telegram.org/bot"$token"/sendMessage" -d "chat_id="${chat_id}"&text=RESULT:
${record}"
    fi
}

main() {
    checkDomain
}

chat_id=$1
domainName=$2
mode=$3
main
