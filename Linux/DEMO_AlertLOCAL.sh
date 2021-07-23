 #!/bin/bash
#chat_id="-1001282086041"
chat_id=""
token=""
interface="ens33" #Network interface
time_report=("16:48" "16:50" "16:52")
# USING THIS FILE TO SAVE OLD WEB STATE
LOG_STATUS_PATH="/root/scripts/domains.status"

mem_threshold=95; cpu_threshold=95; disk_threshold=95; inode_threshold=95; #Percent
bwin_threshold=90; bwout_threshold=90; #MB
my_text=""  #String contain alert
#ip_sv=$(ip a | grep -w inet | grep -Ev "127.0|192.168" | awk '{print $2}' | head -n 1 | awk -F "/" '{print $1}')
ip_sv="192.168.75.50"

# Global Variables
cpu_usage=""
mem_usage=""
disk_usage=""
inode_usage=""
bw=""
bw_incoming=""
bw_outcoming=""
domain_name=("ahihi.com" "tivixiaomi.com")

get_domains_status(){
    result="`cat ${LOG_STATUS_PATH}`"
    if [[ -z $result ]]; then
        for domain in "${domain_name[@]}"; do
            result+="OK "
        done
    fi
    echo $result
}

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
    echo My Text: $my_text
    curl -X POST "https://api.telegram.org/bot"$token"/sendMessage" -d "chat_id="${chat_id}"&text=${my_text}"
    #echo ${my_text} >> /root/scripts/log
}


domain_checker(){
    domains_status=$(get_domains_status)
    declare -i countDomainIndex=0               # Define as Interger
    file_status_content=""
	for dn in "${domain_name[@]}"; do
        # GET old status
        countDomainIndex=$(($countDomainIndex + 1))
        echo $countDomainIndex
        domainOldStatus="$(echo ${domains_status} | cut -d " " -f ${countDomainIndex})"
        echo $dn : $domainOldStatus
        # Checking current
        domainCurrentStatus="OK"
		if [[ -z `curl -I http://"$dn" --connect-timeout 30 | grep 200` ]]; then
			echo -e "Checking $dn"
			curl -I http://"$dn" | grep 200
            domainCurrentStatus="FAIL"
			my_text="⚠️ "$dn" DOWN - Checking now ⚠️ "
			telegram_send
		fi
        # NOTIFY OK AFTER FAIL
        if [[ $domainOldStatus == "FAIL" && $domainCurrentStatus == "OK" ]]; then
            my_text="✅ "$dn" Access OK after FAIL ✅ "
            telegram_send
        fi
        # EXPORT current domain status to FILE
        file_status_content+=${domainCurrentStatus}" "
	done
    echo File: $file_status_content
    echo $file_status_content > ${LOG_STATUS_PATH}
}

domain_checker2(){
    for dn in "${domain_name[@]}"; do
        if [[ ! -z `curl -I http://"$dn" --connect-timeout 30 | grep 200` ]]; then
            echo -e "Checking "$dn""
            curl -I http://"$dn" | grep 200
            my_text="✅ "$dn" Access OK ✅ "
            telegram_send
        fi
    done
}

float_ge() {
    perl -e "{if("$1">="$2"){print 1} else {print 0}}"
}

auto_check() {
    detect_resource
    bw_in=$(echo "${bw_incoming}" | grep "Mbit" | awk '{print $1}')
    bw_out=$(echo "${bw_outcoming}" | grep "Mbit" | awk '{print $1}')
    if \
        [[ $(float_ge "${cpu_usage}" "${cpu_threshold}") == 1 ]] || \
        [[ $(float_ge "${mem_usage}" "${mem_threshold}") == 1 ]] || \
        [[ $(float_ge "${disk_usage}" "${disk_threshold}") == 1 ]] || \
        [[ $(float_ge "${inode_usage}" "${inode_threshold}") == 1 ]] || \
        [[ ! -z "${bw_in}" && $(float_ge "${bw_in}" "${bwin_threshold}") == 1 ]] || \
        [[ ! -z "${bw_out}" && $(float_ge "${bw_out}" "${bwout_threshold}") == 1 ]]; then
        my_text=$(echo -e "⚠️ Problem For "${ip_sv}" ⚠️ 

📢 CPU usage: "${cpu_usage}"%
📢 Memory usage: "${mem_usage}"%
📢 Disk usage: "${disk_usage}"%
📢 Inode usage: "${inode_usage}"%
📢 Bandwith usage: 
  ➡️ In: "${bw_incoming}"
  ⬅️ Out: "${bw_outcoming}"
")
    fi
    telegram_send
}

daily_report(){
    now=$(date "+%H:%M")
    #now=${time_report[0]}
    for i in "${time_report[@]}"
    do
        if [[ "$now" == "$i" ]];
        then
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
        fi
    done
    unset cpu_usage; unset cpu_usage; unset disk_usage; unset bw_in; unset bw_out;
    unset inode_usage; unset bw; unset bw_incoming; unset bw_outcoming;
}

main(){
    #auto_check
    daily_report
    domain_checker
}

main
