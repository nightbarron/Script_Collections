 #!/bin/bash
chat_id="-567723202"        # Default
token="1741302312:AAHUJEV2WsKzCu8wBF6Uq9zwBPL7F724wYoo"
interface="ens192" #Network interface

mem_threshold=95; cpu_threshold=95; disk_threshold=95; inode_threshold=95; #Percent
bwin_threshold=90; bwout_threshold=90; #MB
my_text=""  #String contain alert
#ip_sv=$(ip a | grep -w inet | grep -Ev "127.0|192.168" | awk '{print $2}' | head -n 1 | awk -F "/" '{print $1}')
ip_sv="LOCAL_HOST"

# Global Variables
cpu_usage=""
mem_usage=""
disk_usage=""
inode_usage=""
bw=""
bw_incoming=""
bw_outcoming=""
domain_name=("www.google.com" "vietnix.vn")

detect_resource(){
    #Detect resource usage
    cpu_usage=$(mpstat -P ALL  | grep all | awk '{print $4}' | sed "s/\,/\./g")
    mem_usage=$(free -m | awk '/Mem:/ { printf("%3.1f", $3/$2*100) }')
    disk_usage=$(df -h / | awk '/\// {print $(NF-1)}' | sed "s/%//g")
    inode_usage=$(df -ih / | awk '{print $5}' | sed "s/%//g" | tail -n 1)
    bw=$(vnstat -i "$interface" -tr 3)
    bw_incoming=$(echo "$bw" | grep rx | awk '{printf "%s %s\t PPS: %s %s", $2, $3, $4, $5}')
    bw_outcoming=$(echo "$bw" | grep tx | awk '{printf "%s %s\t PPS: %s %s", $2, $3, $4, $5}')
    # DO NOT NEED TO UPDATE
    #domain_name=("www.tivixiaomi.com")
}

telegram_send(){
    curl -X POST "https://api.telegram.org/bot"$token"/sendMessage" -d "chat_id="${chat_id}"&text=${my_text}"
    #echo ${my_text} >> /root/scripts/log
}

domain_checker2(){
    for dn in "${domain_name[@]}"; do
        echo $dn
        if [[ ! -z `curl -I https://"$dn" --connect-timeout 30 | grep 200` ]]; then
            echo -e "Checking "$dn""
            #curl -I https://"$dn" | grep 200
            my_text="✅ "$dn" Access OK ✅ "
            telegram_send
        else
            my_text="⚠️ "$dn" DOWN - Checking now ⚠️ "
            telegram_send
        fi
    done
}

daily_report(){

    detect_resource
    my_text=$(echo -e "📋 Daily Report For "${ip_sv}" 📋

📢 CPU usage: "${cpu_usage}"%
📢 Memory usage: "${mem_usage}"%
📢 Disk usage: "${disk_usage}"%
📢 Inode usage: "${disk_usage}"%
📢 Bandwith usage: 
➡️ In: "${bw_incoming}"
⬅️ Out: "${bw_outcoming}"
")
    telegram_send
    domain_checker2

    unset cpu_usage; unset cpu_usage; unset disk_usage; unset bw_in; unset bw_out;
    unset inode_usage; unset bw; unset bw_incoming; unset bw_outcoming;
}

main(){
    daily_report
}

chat_id=$1
main

