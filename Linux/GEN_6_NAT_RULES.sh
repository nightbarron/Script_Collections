# VPS: 103.90.225.83 - 10.225.4.83
# FW: 103.90.225.4 - 10.225.4.4


iptables -F -t nat
iptables -F -t raw

# Open port 80
iptables -t nat -A PREROUTING -p tcp --dport 80 -d 103.90.225.4 -j DNAT --to-destination 10.225.4.83:80
iptables -t nat -A POSTROUTING -p tcp -d 10.225.4.83 --dport 80 -j SNAT --to-source 103.90.225.4

# Open port 222
iptables -t nat -A PREROUTING -p tcp --dport 222 -d 103.90.225.4 -j DNAT --to-destination 10.225.4.83:222
iptables -t nat -A POSTROUTING -p tcp -d 10.225.4.83 --dport 222 -j SNAT --to-source 103.90.225.4

#iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to-destination 10.225.4.83:53
#iptables -t nat -A POSTROUTING -p udp -d 10.225.4.83 -j SNAT --to-source 103.90.225.4

#iptables -t nat -A PREROUTING -p tcp --dport 53 -j DNAT --to-destination 10.225.4.83:53
#iptables -t nat -A POSTROUTING -p tcp -d 10.225.4.83 --dport 53 -j SNAT --to-source 103.90.225.4

iptables -t nat -A POSTROUTING -j MASQUERADE

# Drop port
iptables -t raw -I PREROUTING -p tcp --dport=3389 -j DROP

# IP remote, NAT all
iptables -t nat -I PREROUTING -d 103.90.225.83 -j DNAT --to-destination 10.225.4.83
iptables -t nat -I POSTROUTING -s 10.225.4.83 -j SNAT --to-source 103.90.225.83
iptables -t raw -I PREROUTING -d 103.90.225.83 -j ACCEPT

iptables -F FORWARD
iptables -A FORWARD -i eth0 -j ACCEPT
iptables -A FORWARD -o eth0 -j ACCEPT