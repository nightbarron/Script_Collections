#!/bin/bash
#statusCode=$(curl --connect-timeout 30 --write-out '%{http_code}' --silent --output /dev/null https://ahihi.com)
statusCode="300"
echo "Status: ${statusCode}"
if [[ ${statusCode} =~ ^2.{2}$|^000$ ]]; then
    echo "valid number"
else
    echo "not valid number, try again"
fi