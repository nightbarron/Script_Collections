#!/bin/bash 

function disable() {
	sudo systemctl stop firewalld
	sudo systemctl disable firewalld
	sudo systemctl mask --now firewalld
	sed -i '' -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
}

function config() {
	#sed -i '' -e "s/#PermitRootLogin/PermitRootLogin/g" /etc/ssh/sshd_config
	sed -i.bak '/PermitRootLogin/d' /etc/ssh/sshd_config
	echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
	service sshd restart
	chmod +x /etc/rc.local

	if [[ $OS == "6" ]]; then
		rm -rf /etc/yum.repos.d/CentOS*
		touch /etc/yum.repos.d/CISP.repo	
cat <<EOF > /etc/yum.repos.d/CISP.repo
[CISP]
name=CISP Repository
baseurl=http://mirror.cisp.com/CentOS/6/os/x86_64/
enabled=1
gpgcheck=1
gpgkey=http://mirror.cisp.com/CentOS/6/os/x86_64/RPM-GPG-KEY-CentOS-6
EOF
	fi
}

function ubuntu() {
	installArr=("sudo apt-get update && sudo apt-get upgrade -y"
				"sudo apt install tcpdump -y"
				"sudo apt install telnet -y")

	for i in "${installArr[@]}"; do $i; done
	#echo -e 'vietnix@2016\nvietnix@2016' | sudo passwd root
	#sudo deluser --remove-home $USER
}

function centos() {
	installArr=("yum update -y"
                "yum upgrade -y"
				"yum install tcpdump -y"
				"yum install telnet -y"
				"yum install net-tools -y"
				"yum install vim -y")

	for i in "${installArr[@]}"; do $i; done
}

function main() {
	OS=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f1)
	if [[ $OS == "6" || $OS == "7" ]]
	then
		disable
		config
		centos
	else
		disable
		config 
		ubuntu
	fi
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="intel_pstate=disable"' >> /etc/default/grub
    grub2-mkconfig > /boot/grub2/grub.cfg
	grub2-mkconfig > /boot/efi/EFI/centos/grub.cfg

}

main
