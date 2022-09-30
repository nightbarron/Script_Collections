#!/bin/bash

installWireguard() {
    sudo apt-get update
    sudo apt install resolvconf wget gnome-shell-extensions -y
    sudo apt-get install wireguard -y
}

allowPort() {
    sudo ufw allow 41194/udp
}

enableWg() {
    systemctl enable wg-quick@wg0
}

installWGIndicator() {
    cd ~/Downloads
    wget https://extensions.gnome.org/extension-data/wg-indicatorasterios.member.fsf.org.v2.shell-extension.zip
    gnome-extensions install wg-indicatorasterios.member.fsf.org.v2.shell-extension.zip
    gnome-extensions enable wg-indicator@asterios.member.fsf.org
}

getConfigFile() {
    read -p 'Enter VPN Config file path: ' vpnDir
    sudo cp ${vpnDir} /etc/wireguard/wg0.conf
    sudo chown 755 /etc/wireguard/wg0.conf
}

addBashrc() {
    echo "alias startWorking='sudo systemctl start wg-quick@wg0'" >> $HOME/.bashrc
    echo "alias stopWorking='sudo systemctl stop wg-quick@wg0'" >> $HOME/.bashrc
    source $HOME/.bashrc
}

manual() {
    echo "Success!!! VPN Already configures!!!"
    echo "Now, Your task is: "
    echo "[+] Take Rebull, while restart your Laptop"
    echo "[+] To Start VPN: Open Terminal and run \"startWorking\""
    echo "[+] To Stop VPN: Open Terminal and run \"stopWorking\""
    echo "Goodluck <3!"
}

checkUbuntu() {
    linuxVersion=`uname -a | grep Ubuntu`
    echo ${#linuxVersion} 
    if [ ${#linuxVersion} -lt 3 ] 
    then
        echo "Your OS need Ubuntu related to run this script!!!"
        exit
    fi 
}

main() {

    checkUbuntu
    installWireguard
    allowPort
    installWGIndicator
    getConfigFile
    addBashrc
    # enableWg
    # systemctl start wg-quick@wg0
    manual
}

main


# [Desktop Entry]
# Version=1.0
# Exec=`/root/scripts/wg-start.sh`
# Name=SSH Server
# GenericName=SSH Server
# Comment=Connect to My Server
# Encoding=UTF-8
# Terminal=true
# Type=Application
# Categories=Application;Network;

