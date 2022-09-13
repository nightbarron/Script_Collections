#!/bin/bash
# Ubuntu 20.02

sudo apt-get install wireguard -y
sudo apt install openresolv -y

# umask 077
# wg genkey | tee privatekey | wg pubkey > publickey

# Add config from server to /etc/wireguard/wg0.conf

# Generate desktop
# sudo apt install zenity
# mkdir -p ~/.wireguard
# nano ~/.wireguard/wireguard.sh

# sudo nmcli connection import type wireguard file /etc/wireguard/wg0.conf

systemctl start wg-quick@wg0


