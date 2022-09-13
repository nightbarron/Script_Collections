#!/bin/bash

function ruleLimitAccount() {
    read -p 'Enter your IPFW: ' ipfw

    read -p 'Enter IP mem: ' ipMem

    read -p 'Enter number account/IP: ' accounts

    read -p 'Enter port to limit: ' portLimit

    echo "=================Here your Rules================="

    echo "iptables -t raw -F connect_limit"

    # if [[ $ipMem == null ]];
    # then
    #     echo "no ip mem"
    # fi

    if [ -z "$ipMem" ]; 
    then 
        echo "iptables -t raw -I connect_limit -d "${ipfw}"/32 -m tcp -p tcp --syn -m multiport --dports "${portLimit}" -m connlimit --connlimit-above "${accounts}" --connlimit-mask 32 --connlimit-saddr -m comment --comment "\"Khach yeu cau "${accounts}" accounts/IP\"" -j DROP"; 
    else 
        echo "iptables -t raw -I connect_limit -s "${ipMem}" -d "${ipfw}"/32 -m tcp -p tcp --syn -m multiport --dports "${portLimit}" -m connlimit --connlimit-above "${accounts}" --connlimit-mask 32 --connlimit-saddr -m comment --comment "\"Khach yeu cau "${accounts}" accounts/IP\"" -j DROP";
    fi

    
}

function ruleLimitRemote() {
    read -p 'Enter IP remote: ' ipRemote

    read -p 'Enter IP to allow remote: ' ipAllowRemote

    echo "=================Here your Rules================="

    echo "iptables -t raw -I NAT -p tcp -d "${ipRemote}"/32 --dport 3389 -j DROP"
    echo "iptables -t raw -I NAT -p tcp -s "${ipAllowRemote}"/32 -d "${ipRemote}"/32 -j ACCEPT"
}

function ruleNAT_Port() {
    read -p 'Enter your IPFW: ' ipfw

    read -p 'Enter IP local backend: ' ipLocal

    read -p 'Enter port to NAT: ' portNAT

    echo "=================Here your Rules================="

    echo "iptables -t nat -A PREROUTING -d "${ipLocal}"/32 -p tcp -m tcp -m multiport --dports "${portNAT}" -j DNAT --to-destination "${ipfw}
}


function main() {
    echo "1. Rule FW limit account/IP"
    echo "2. Rule Limit Remote Desktop"
    echo "3. Rule NAT port in Backend"
    echo "4. Rule..."
    echo "5. Rule..."
    echo "6. Exit"
    read -p 'Enter your option: ' option

    case "$option" in
    "1")
        ruleLimitAccount
        ;;
    "2")
        ruleLimitRemote
        ;;
    "3")
        ruleNAT_Port
        ;;
    "4")
        #rule...
        ;;
    "5")
        #rule...
        ;;    
    "*")
        break;
        ;;
    esac

}

main
