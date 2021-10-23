#!/bin/bash
sudo yum install epel-release elrepo-release git -y
sudo yum install yum-plugin-elrepo -y 
sudo yum install kmod-wireguard wireguard-tools -y
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p 

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io docker-compose -y
service docker start
systemctl enable docker

echo "[Unit]
Description=Restart WireGuard
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/systemctl restart wg-quick@wg0.service

[Install]
RequiredBy=wgui.path" > /etc/systemd/system/wgui.service

echo "[Unit]
Description=Watch /etc/wireguard/wg0.conf for changes

[Path]
PathModified=/etc/wireguard/wg0.conf

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/wgui.path

systemctl enable wgui.{path,service}
systemctl start wgui.{path,service}

echo "#!/bin/sh
wg-quick down wg0
wg-quick up wg0" > /usr/local/bin/wgui

chmod +x /usr/local/bin/wgui

echo "#!/sbin/openrc-run
command=/sbin/inotifyd
command_args="/usr/local/bin/wgui /etc/wireguard/wg0.conf:w"
pidfile=/run/${RC_SVCNAME}.pid
command_background=yes" > /etc/init.d/wgui

chmod +x /etc/init.d/wgui

mkdir /home/docker
cd /home/docker
git clone https://github.com/ngoduykhanh/wireguard-ui

cd /home/docker/wireguard-ui
sed -i 's/alpha/admin/' docker-compose.yaml
sed -i 's/this-unusual-password/VxeecVShSsw1ree/' docker-compose.yaml
docker-compose up -d

mkdir /root/scripts
echo "cd /home/docker/wireguard-ui && docker-compose up -d
systemctl start wgui" > /root/scripts/reboot.sh
chmod +x /root/scripts/reboot.sh
echo "@reboot /bin/bash /root/scripts/reboot.sh" >> /var/spool/cron/root



# Config in GUI
# 6. Config in Giao dien

#     Global Settings -> Check IP/ DNS: 1.1.1.1/8.8.8.8/ MTU: 1450
#     Wireguard Server -> Listen Port: 51820 / 
#     Post Up Script:
#     /sbin/iptables -A FORWARD -i wg0 -j ACCEPT; /sbin/iptables -t nat -A POSTROUTING -s 10.252.1.0/24 -o eth0 -j MASQUERADE
#     Post Down Script:
#     /sbin/iptables -D FORWARD -i wg0 -j ACCEPT; /sbin/iptables -t nat -D POSTROUTING -s 10.252.1.0/24 -o eth0 -j MASQUERADE

#     -> Apply config

# 7. Start 
#     #wg-quick up wg0
#     systemctl restart wgui.{path,service}
