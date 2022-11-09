#!/bin/bash
sshR(){
    ssh root@$1
}

rdp(){
    remmina -c rdp://Administrator@$1
}

helpCenter() {
    echo "NAME
    frm - Fast Remote for SSH and RDP

SYNOPSIS
    frm [options] [ip]

OPTIONS
    -r, --rdp=ip
            Remote for Windows

    -s, --ssh=ip
            Make a checking if SSL for domain is valid or not.

    -h, --help
            Show help options for fastRemote tool."
}

main() {
    option=$1
    ip=$2
    if [[ ${option} = "-r" || ${option} = "--rdp" ]]
    then
        rdp ${ip}
    elif [[ ${option} = "-s" || ${option} = "--ssh" ]]
    then
        sshR ${ip}
    elif [[ ${option} = "-h" || ${option} = "--help" ]]
    then
        helpCenter
    else
        echo "Invalid options! Type -h or --help to see more."
    fi
    echo "Exit!"
    exit 0
}

main $1 $2