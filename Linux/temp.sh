#Allow node exporter port (26)
iptables -t raw -I CUSTOM -s 103.90.226.18 -p tcp --dport 26 -j ACCEPT
iptables -t raw -I CUSTOM -s 118.69.63.53 -p tcp --dport 26 -j ACCEPT
iptables -t raw -I CUSTOM -s 171.244.18.3 -p tcp --dport 26 -j ACCEPT

iptables -t nat -I SYNPROXY_CHAIN -s 103.90.226.18 -p tcp -m multiport --dports 26 -j RETURN
iptables -t nat -I SYNPROXY_CHAIN -s 118.69.63.53 -p tcp -m multiport --dports 26 -j RETURN
iptables -t nat -I SYNPROXY_CHAIN -s 171.244.18.3 -p tcp -m multiport --dports 26 -j RETURN
#End allow node exporter port (26)
#chan quoc te
#iptables -t raw -I CUSTOM  -m set ! --match-set VN_IP_RANGE src  -m comment --comment "chan quoc te den proxy" -j DROP

iptables -t raw -F connect_limit


#iptables -t raw -t mangle -I PREROUTING  -p tcp -d 103.200.21.213  -m multiport --dports 7000:8000 -m hashlimit --hashlimit-above 10/sec --hashlimit-burst 15 --hashlimit-mode srcip,srcport,dstip,dstport --hashlimit-name limitpkgperconnect -j DROP
#iptables -t raw -t mangle -I PREROUTING  -p tcp -d 103.200.21.213  -m multiport --dports 7000:8000 -m hashlimit --hashlimit-above 15/sec --hashlimit-burst 15 --hashlimit-mode srcip,srcport,dstip,dstport --hashlimit-name limitpkgperconnect -j LOG --log-prefix "IP packet rate exceeded: "

iptables -t raw -I NAT -p tcp -m tcp --syn -d 103.200.21.248 --dport 5622 -j DROP
iptables -t raw -I NAT -p tcp -m tcp --syn -d 103.200.21.235 --dport 4601 -j DROP

# PhongThan - Firewall Login
iptables -t raw -A CUSTOM  -d 103.200.21.216/32 -p tcp -m tcp --syn --dport 4601 -m set --match-set client_sign_verified src -j ACCEPT
iptables -t raw -A CUSTOM  -p icmp -m ttl  --ttl-gt  128 -m string --string "kingsoft" --algo kmp  -j SET --add-set client_sign_verified src --exist  --timeout 259200
iptables -t raw -A CUSTOM  -d 103.200.21.216/32 -p tcp -m tcp --syn --dport 4601 -m set ! --match-set client_sign_verified src -j DROP
# thuc
# khach yeu cau 1 ip chi duoc 1 ket noi den port login
iptables -t raw -F connect_limit
iptables -t raw -I connect_limit -p tcp --syn -d 103.200.21.216 -m multiport --dports 4601 -m connlimit --connlimit-above 1 --connlimit-mask 32 --connlimit-saddr -m comment --comment "Khach yeu cau 1 accounts/IP" -j DROP
#iptables -t raw -I WHITELIST -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j connect_limit


#CUSTOM - NEW RULE FOR MASON-MY
#iptables -t raw -I CUSTOM -m set --match-set real_clients src -j RETURN
#iptables -t raw -A CUSTOM -d 103.200.21.216 -j DROP

#khanh
# iptables -t mangle -I PREROUTING -p tcp -d 103.200.21.213 -m multiport --dport 7000:8000 -j packetavg
# iptables -t mangle -I PREROUTING -p tcp -d 103.200.21.216 -m multiport --dport 4601:4602 -j packetavg

#khach bao tat
#iptables -t mangle -A packetavg -p tcp -d 103.200.21.213 -m multiport --dports 7000:8000 -m set ! --match-set sockets src,src,dst --update-counters -j SET --add-set sockets src,src,dst --timeout 15
#iptables -t mangle -A packetavg -p tcp -d 103.200.21.213 -m set --match-set sockets src,src,dst  ! --update-counters --packets-lt 150 -j RETURN

#iptables -t mangle -A packetavg -p tcp -d 103.200.21.216 -m multiport --dports 7000:8000 -j DROP

#iptables -t mangle -A packetavg -p tcp -d 103.200.21.216 -m multiport --dports 4601:4602 -m set ! --match-set sockets src,src,dst --update-counters -j SET --add-set sockets src,src,dst --timeout 15
#iptables -t mangle -A packetavg -p tcp -d 103.200.21.216 -m set --match-set sockets src,src,dst  ! --update-counters --packets-lt 7 -j RETURN
#iptables -t mangle -A packetavg -p tcp -d 103.200.21.216 -m multiport --dports 4601:4602 -j DROP
#iptables -t mangle -A packetavg -j LOG --log-prefix "IP packet rate "


#TuanDLH
# Khach yeu cau 3 connection lien tuc trong vong 15s
#iptables -t mangle -A PREROUTING -p tcp --dport 4601 -d 103.200.21.216 -m conntrack --ctstate NEW -m recent --set --name LOGIN --rsource
#iptables -t mangle -A PREROUTING -p tcp --dport 4601 -d 103.200.21.216 -m conntrack --ctstate NEW -m recent --update --seconds 15 --hitcount 3 --name LOGIN --rsource -j DROP

#iptables -t mangle -I PREROUTING 1 -p tcp -s 103.200.21.216 --dport 4601 -m state --state NEW -m recent --set --mask 255.255.255.255 --name DEFAULT -j LOG
#iptables -t mangle -I PREROUTING 2 -p tcp -s 103.200.21.216 --dport 4601 -m state --state NEW -m recent --update --seconds 1 --mask 255.255.255.255 --hitcount 15 --name DEFAULT -j DROP


#limit 103.200.21.235
iptables -t raw -I PREROUTING -d 103.200.21.235 -j DROP
iptables -t raw -I PREROUTING -d 103.200.21.235 -m set --match-set WHITELIST_Src src  -j ACCEPT


#limit backend 103.200.21.249
iptables -t raw -I NAT -p tcp -d 103.200.21.249 -m set ! --match-set WHITELIST_Src src  -m comment --comment "limit backend 103.200.21.249 ACCEPT" -j DROP


##################################
# Chỉ cho phép IP whitelist được phép truy cập cổng game
iptables -t raw -A CUSTOM  -p tcp -m tcp --syn -m multiport --dports 4601:4603,5622:5625,5122:5132,7000:8000,6660:6680 -m set ! --match-set client_sign_verified src -j DROP
iptables -t raw -A CUSTOM  -d 103.200.21.100/32 -p tcp -m tcp --syn -m multiport --dports 5622:5625,5122:5132,6661:6665,7000:8000,1111 -m set ! --match-set client_sign_verified src -j DROP
iptables -t raw -A CUSTOM  -d 103.200.21.213/32 -p tcp -m tcp --syn -m multiport --dports 4601:4603,5622:5625,5122:5132,6661:6665,7000:8000,1111 -m set ! --match-set client_sign_verified src -j DROP

# Chặn truy cập trực tiếp IP remote
iptables -t raw -I NAT -p tcp -d 103.200.21.165 -m multiport --dports 80,2624,5622:5623,6661:6665,9551 -j DROP
iptables -t raw -I NAT -p tcp -d 103.200.21.249 -m multiport --dports 80,2624,4601:4603,5622:5623,6661:6665,7000:8000,9551 -j DROP


##################################
#2: Giới hạn số kết nối tối đa cho từng IP đến cổng login
iptables -t raw -A connect_limit -p tcp --syn -d 103.200.21.100 -m multiport --dports 5622:5624 -m connlimit --connlimit-above 1 --connlimit-mask 32 --connlimit-saddr -m comment --comment "limit 1 connect/IP" -j DROP
iptables -t raw -A connect_limit -p tcp --syn -d 103.200.21.213 -m multiport --dports 4601:4603 -m connlimit --connlimit-above 1 --connlimit-mask 32 --connlimit-saddr -m comment --comment "limit 1 connect/IP" -j DROP

#3: Giới hạn tổng số kết nối tối đa đến cổng login
iptables -t raw -A connect_limit  -p tcp --syn -d 103.200.21.100 -m multiport --dports 5622:5624 -m connlimit --connlimit-above 15 --connlimit-mask 32 --connlimit-daddr -m comment --comment "limit N connect/IP" -j DROP
iptables -t raw -A connect_limit  -p tcp --syn -d 103.200.21.213 -m multiport --dports 4601:4603 -m connlimit --connlimit-above 15 --connlimit-mask 32 --connlimit-daddr -m comment --comment "limit N connect/IP" -j DROP

#4: Giới hạn số kết nối tối đa cho từng IP đến cổng gameserver
iptables -t raw -A connect_limit  -p tcp --syn -d 103.200.21.100 -m multiport --dports 6661:6665 -m connlimit --connlimit-above 10 --connlimit-mask 32 --connlimit-saddr -m comment --comment "Khach yeu cau 10 accounts/IP" -j DROP
iptables -t raw -A connect_limit  -p tcp --syn -d 103.200.21.213 -m multiport --dports 7000:8000 -m connlimit --connlimit-above 10 --connlimit-mask 32 --connlimit-saddr -m comment --comment "Khach yeu cau 10 accounts/IP" -j DROP

#5: Sau khi afk 15 giây ở cổng login --> firewall hủy kết nối và chặn login trong một khoảng thời gian
iptables -nvL INPUT ; ipset create reset hash:ip timeout 0
iptables -t filter -A OUTPUT -o p3p1 -p tcp -s 103.200.21.100 -m multiport --sports 5622:5624 -m tcp --tcp-flags FIN,ACK FIN,ACK -j SET --add-set reset dst --timeout 15
iptables -t filter -A OUTPUT -o p3p1 -p tcp -s 103.200.21.213 -m multiport --sports 4601:4603 -m tcp --tcp-flags FIN,ACK FIN,ACK -j SET --add-set reset dst --timeout 15
iptables -t raw -A BLACKLIST -p tcp  -m tcp --syn -m set --match-set reset src -m multiport --dports 4601:4603,5622:5624 -j DROP

#6: Mỗi kết nối nếu gửi tối đa số lượng gói tin trong khoảng thời gian nhất định. Thực hiện reset kết nối và chặn login trong một khoảng thời gian
iptables -nvL INPUT ; ipset create ratecheck hash:ip,port,ip timeout 0 counters
iptables -t filter -N ratecheck
iptables -t filter -F ratecheck
iptables -t filter -N ratetrigger
iptables -t filter -F ratetrigger
        iptables -t filter -A ratetrigger -p tcp -j SET --add-set reset src --timeout 60
        iptables -t filter -A ratetrigger -p tcp -j REJECT --reject-with tcp-rst
        iptables -t filter -A ratecheck -p tcp -m set ! --match-set ratecheck src,src,dst   --update-counters   -j SET --add-set ratecheck src,src,dst --timeout 15
        iptables -t filter -A ratecheck -p tcp -m set   --match-set ratecheck src,src,dst ! --update-counters --packets-gt 15 -j ratetrigger
iptables -t filter -I INPUT 4 -i p3p1+ -d 103.200.21.100/32 -p tcp -m tcp -m multiport --dports 5622:5624 -m conntrack --ctstate ESTABLISHED --ctdir ORIGINAL -j ratecheck
iptables -t filter -I INPUT 4 -i p3p1+ -d 103.200.21.213/32 -p tcp -m tcp -m multiport --dports 4601:4603 -m conntrack --ctstate ESTABLISHED --ctdir ORIGINAL -j ratecheck

#7: Giới hạn tần suất kết nối mới cho từng IP đến cổng login
iptables -nvL INPUT ; ipset create login_permin hash:ip timeout 0 counters
iptables -t raw -A BLACKLIST -p tcp  -m tcp --syn -m set --match-set login_permin src  --packets-gt 4 ! --update-counters -m multiport --dports 4601:4603,5622:5624 -j DROP
iptables -t filter -A OUTPUT -p tcp  -s 103.200.21.100 -m multiport --sports 5622:5624 -m tcp --tcp-flags SYN,ACK SYN,ACK -m set ! --match-set login_permin dst   --update-counters   -j SET --add-set login_permin dst --timeout 60
iptables -t filter -A OUTPUT -p tcp  -s 103.200.21.213 -m multiport --sports 4601:4603 -m tcp --tcp-flags SYN,ACK SYN,ACK -m set ! --match-set login_permin dst   --update-counters   -j SET --add-set login_permin dst --timeout 60
iptables -t filter -A OUTPUT -p tcp  -s 103.200.21.100 -m multiport --sports 5622:5624 -m tcp --tcp-flags SYN,ACK SYN,ACK -m set   --match-set login_permin dst ! --update-counters
iptables -t filter -A OUTPUT -p tcp  -s 103.200.21.213 -m multiport --sports 4601:4603 -m tcp --tcp-flags SYN,ACK SYN,ACK -m set   --match-set login_permin dst ! --update-counters
