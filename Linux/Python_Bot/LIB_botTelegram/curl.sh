 #!/bin/bash
chat_id="-567723202"        # Default
domainName=""
token="1741302312:AAHUJEV2WsKzCu8wBF6Uq9zwBPL7F724wYoo"

# pip install sslchecker

checkCurl() {
    
    curl -I ${url} &> /tmp/ssl.tmp
    result="$(cat /tmp/ssl.tmp | grep -Pzo 'HTTP((.|\n)*)')"
    rm -rf /tmp/ssl.tmp

    curl -X POST "https://api.telegram.org/bot"$token"/sendMessage" -d "chat_id="${chat_id}"&text= RESULT:
    
${result}"
}

main() {
    checkCurl
}

chat_id=$1
url=$2
main
