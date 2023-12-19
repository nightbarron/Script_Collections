#!/usr/bin/env bash
declare -a -r 	INTERFACES=( $(ip link show | grep -v '@' | awk '/state UP/ {gsub(":","",$2) ; print $2}') )
declare -r 	CPUS=$(awk '/^processor/ {i++} END{print i}' /proc/cpuinfo)
#declare -r 	RPS_BITMAPS=4
declare		RPS_BITMAPS=4
declare -r 	XPS_BITMAPS=2
declare -r 	RPS_SOCK_FLOW_ENTRIES=32768

function cmd () {

	LOG_FILE="${LOG_FILE:=/dev/null}"
	local timestamp=`date +%Y-%m-%d:%H:%M`
	if ${DEBUG:=true} ; then
		echo -e "[$timestamp ${FUNCNAME[1]}]: ${@}" | tee -a ${LOG_FILE} 1>&2
	else
		echo -e "[$timestamp ${FUNCNAME[1]}]: ${@}" >> ${LOG_FILE}
	fi

        bash -c "${@}"
        if [ $? -ne 0 ]; then
        	echo -e "ERROR when Run: \n ${@}" | tee -a ${LOG_FILE} >&2
                exit 1
        fi
}

function pre_action() {

	cmd "#disable irqbalances"
	systemctl stop irqbalance
	systemctl disable irqbalance
}

post_action () {

        cat <<- _EOF_


        Done. Have a nice day!


_EOF_
}

function rss() {
	for int in ${INTERFACES[@]}
	do
		irqs=($(grep -E "${int}-" /proc/interrupts | awk '{print $1}' | tr -d ':'))
		cpu=$CPUS

		for irq in "${irqs[@]}"
		do
			declare -a smp_map=()
			[[ ! $cpu -ge 0 ]] && break
			smp_map_tmp="1"
			for (( i=cpu-1 ; i > 0 ; i-- ))
			do
				smp_map_tmp+=0
			done

			# Strip each 32 bit of smp_map_tmp to smp_map[]
			while [ ${#smp_map_tmp} -gt 32 ]
			do
				echo ${#smp_map_tmp}
				smp_map_tmp=${smp_map_tmp:0:${#smp_map_tmp} - 32}
				smp_map=("0" "${smp_map[@]}")
			done

			# for (( idx=${#MYARRAY[@]}-1 ; idx>=0 ; idx-- )) ; do
			# 	echo "${MYARRAY[idx]}"
			# done


			smp_map=(`printf '%x\n' "$((2#${smp_map_tmp}))"` "${smp_map[@]}")
			cmd "#--> bitmap=${smp_map[@]} | cpu=$cpu | irq=$irq "
			map=`echo ${smp_map[@]} | tr " " ","`
			cmd "echo ${map} > /proc/irq/${irq}/smp_affinity"
			let "cpu--"

			unset smp_map
		done

	done
}

function rxps() {

	for int in ${INTERFACES[@]}
        do
		# rps
		for rps_cpus in /sys/class/net/${int}/queues/rx-*/rps_cpus
		do
			# create randomly rps_position
			declare -A rps_position=()
			if (( ${RPS_BITMAPS} > ${CPUS} ))
			then
				RPS_BITMAPS=${CPUS}
			fi
			for (( i = 1; i <= RPS_BITMAPS; i++ ))
			do
				num=$(( (RANDOM % CPUS ) + 1 ))
				# BUG HERE
				while (( ${#rps_position[$num]} > 0 ))
				do
					num=$(( (RANDOM % CPUS ) + 1 ))
				done
				rps_position[$num]=$num
			done
			# Create rps_bitmap
			declare -a rps_bitmap=()
			rps_bitmap_tmp=""
			for (( i=CPUS; i> 0; i-- ))
			do
				if (( rps_position[$i] ))
				then
					rps_bitmap_tmp+=1
				else
					rps_bitmap_tmp+=0
				fi
			done

			# Strip each 32 bit to one hex value
			while [ ${#rps_bitmap_tmp} -gt 32 ]
			do
				tmp=${rps_bitmap_tmp:${#rps_bitmap_tmp} - 32:32}
				value=`printf '%x' $(( 2#${tmp} ))`
				rps_bitmap_tmp=${rps_bitmap_tmp:0:${#rps_bitmap_tmp} - 32}
				rps_bitmap=("${value}" "${rps_bitmap[@]}")
			done

			unset value
			value=`printf '%x' $(( 2#${rps_bitmap_tmp} ))`
			rps_bitmap=("${value}" "${rps_bitmap[@]}")

			cmd "#--> File: $rps_cpus | CPUs: ${rps_position[@]} | rps_bitmap: ${rps_bitmap[@]} "

			map=`echo ${rps_bitmap[@]} | tr " " ","`
			cmd "echo ${map} > ${rps_cpus}"

			unset rps_bitmap
		done

		# xps
                for xps_cpus in /sys/class/net/${int}/queues/tx-*/xps_cpus
                do
                        # create randomly xps_position
                        declare -A xps_position=()
                        for (( i = 1; i <= XPS_BITMAPS; i++ ))
                        do
                                num=$(( (RANDOM % CPUS ) + 1 ))
                                while (( xps_position[$num] ))
                                do
                                        num=$(( (RANDOM % CPUS ) + 1 ))
                                done
                                xps_position[$num]=$num
                        done

                        # Create xps_bitmap
						declare -a xps_bitmap=()

                        xps_bitmap_tmp=""
                        for (( i=CPUS; i> 0; i-- ))
                        do
                                if (( xps_position[$i] ))
                                then
                                        xps_bitmap_tmp+=1
                                else
                                        xps_bitmap_tmp+=0
                                fi
                        done

						while [ ${#xps_bitmap_tmp} -gt 32 ]
						do
							tmp=${xps_bitmap_tmp:${#xps_bitmap_tmp} - 32:32}
							value=`printf '%x' $(( 2#${tmp} ))`
							xps_bitmap_tmp=${xps_bitmap_tmp:0:${#xps_bitmap_tmp} - 32}
							xps_bitmap=("${value}" "${xps_bitmap[@]}")
						done

						unset value
						value=`printf '%x' $(( 2#${xps_bitmap_tmp} ))`
						xps_bitmap=("${value}" "${xps_bitmap[@]}")

                        cmd "#--> File: $xps_cpus | CPUs: ${xps_position[@]} | xps_bitmap: ${xps_bitmap[@]} "

						map=`echo ${xps_bitmap[@]} | tr " " ","`
                        cmd "echo ${map} > ${xps_cpus}"

						unset xps_bitmap
                done
	done
}

function rfs() {

	cmd "# echo ${RPS_SOCK_FLOW_ENTRIES} > /proc/sys/net/core/rps_sock_flow_entries"

	interfaces="${INTERFACES[@]}"
	pattern="${interfaces// /|}"
	rps_flows=( $(ls /sys/class/net/*/queues/rx-*/rps_flow_cnt | grep -E "/($pattern)/") )
	rps_flows_count=${#rps_flows[@]}
	rps_value=$(( RPS_SOCK_FLOW_ENTRIES / rps_flows_count ))

	for rps_flow_cnt in "${rps_flows[@]}"
	do
		cmd "echo $rps_value > ${rps_flow_cnt}"
	done
}

main () {

    pre_action

    rss
    rxps
    rfs
    #accelerated_rfs

    post_action
}

main