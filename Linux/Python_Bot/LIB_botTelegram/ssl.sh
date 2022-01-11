 #!/bin/bash
chat_id="-567723202"        # Default
domainName=""
token="1741302312:AAHUJEV2WsKzCu8wBF6Uq9zwBPL7F724wYoo"

# pip install sslchecker

checkSSL() {
    curl -vI https://${domainName} &> /tmp/ssl.tmp
    result="$(cat /tmp/ssl.tmp | grep -Pzo '\* Server certificate:((.|\n)*(C=.*))')"
    rm -rf /tmp/ssl.tmp
    if [[ ${#result} -eq 0 ]]; then
        curl -X POST "https://api.telegram.org/bot"$token"/sendMessage" -d "chat_id="${chat_id}"&text= ⚠️ ${domainName} ⚠️ don't have SSL"
    else
        curl -X POST "https://api.telegram.org/bot"$token"/sendMessage" -d "chat_id="${chat_id}"&text=${result}"
    fi
}

main() {
    checkSSL
}

chat_id=$1
domainName=$2
main
