 #!/bin/bash
chat_id="-567723202"        # Default
domainName=""
token="1741302312:AAHUJEV2WsKzCu8wBF6Uq9zwBPL7F724wYoo"

# pip install sslchecker

randomPass() {
    if [ ${#length} -lt 2 ]; then
        length=10
    fi 
    result="$(tr -dc A-Za-z0-9 </dev/urandom | head -c ${length} ; echo '')"
    curl -X POST "https://api.telegram.org/bot"$token"/sendMessage" -d "chat_id="${chat_id}"&text= PASS: ${result}"
}

main() {
    randomPass
}

chat_id=$1
length=$2
main
