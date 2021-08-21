#!/bin/bash
# author: Night Barron
# Date: 14/06/2021

 #!/bin/bash
chat_id="-567723202"        # Default
domainName=""
organName=""
provinceName=""
emailAddress=""
token="1741302312:AAEYs97TnxuuKKvq5h94IARA1haWyNAG21E"

createSSL() {

    fileName=${domainName/"*"/"_"}
    location=$(pwd)

    location=$location"/${fileName}"
    mkdir -p $location
    {
        openssl req -new -newkey rsa:2048 -nodes -out "${location}/${fileName}.csr" -keyout "${location}/${fileName}.key" \
        -subj "/C=VN/ST=${provinceName}/L=${provinceName}/O=${organName}/OU=IT Department/CN=${domainName}/emailAddress=${emailAddress}"

        curl "https://api.telegram.org/bot"$token"/sendDocument?chat_id="${chat_id} -F document=@"${location}/${fileName}.csr"
        curl "https://api.telegram.org/bot"$token"/sendDocument?chat_id="${chat_id} -F document=@"${location}/${fileName}.key"
        rm -rf ${location}
    } || {
        result="⚠️ Can't Create CSR, KEY for ${domainName} ⚠️"
        curl -X POST "https://api.telegram.org/bot"$token"/sendMessage" -d "chat_id="${chat_id}"&text=${result}"
        return 0
    }
}

main() {
    createSSL
}

chat_id=$1
domainName=$2
organName=$3
provinceName=$4
emailAddress=$5
main