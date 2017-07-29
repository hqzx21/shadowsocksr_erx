#!/bin/bash
set -e
echo "Please input your shadowsocksr configration step by step."
echo "Just press ENTER if you use default config."
echo 
read -p "server address (default: changeme.fuckgfw.com):" ss_server
[ -z "${ss_server}" ] && ss_server="changeme.fuckgfw.com"
read -p "server port (default: 22222):" ss_port
[ -z "${ss_port}" ] && ss_port="22222"
read -p "password (default: 12345678):" ss_password
[ -z "${ss_password}" ] && ss_password="ss_password"
read -p "method (default: aes-256-cfb):" ss_method
[ -z "${ss_method}" ] && ss_method="aes-256-cfb"
read -p "protocol (default: origin):" ss_protocol
[ -z "${ss_protocol}" ] && ss_protocol="origin"
read -p "obfs (default: plain):" ss_obfs
[ -z "${ss_obfs}" ] && ss_obfs="plain"
echo
echo "Please input your ISP dns or public dns you want to use"
read -p "(default: 114.114.114.114):" public_dns
[ -z "${public_dns}" ] && public_dns="114.114.114.114"
echo
echo "---------------------------"
echo "ss_server= $ss_server"
echo "ss_port= $ss_port"
echo "ss_password= $ss_password"
echo "ss_method= $ss_method"
echo "ss_protocol= $ss_protocol"
echo "ss_obfs= $ss_obfs"
echo "public_dns= $public_dns"
echo "---------------------------"
echo

cat > ./config/shadowsocksr/conf/shadowsocksr.json<<-EOF
{
    "server":"$ss_server",
    "server_port":$ss_port,
    "local_address":"0.0.0.0",
    "local_port":8888,
    "password":"$ss_password",
    "timeout":300,
    "method":"$ss_method",
    "protocol": "$ss_protocol",
    "obfs": "$ss_obfs"
}
EOF
echo "write shadowsocksr.json success"

#copy files
sed -i "s/ISPDNS=114.114.114.114/ISPDNS=$public_dns/" ./etc/init.d/shadowsocksr
cp -f ./etc/init.d/shadowsocksr /etc/init.d/
cp -rf ./config/shadowsocksr /config
chmod +x /etc/init.d/shadowsocksr
chmod +x /config/shadowsocksr/bin/*
echo "copy file ok"

#change dnsmasq config
dnscfg=/etc/dnsmasq.conf
[ 0 == `grep "^log-facility" $dnscfg|wc -l` ] && echo log-facility=/var/log/dnsmasq.log >> $dnscfg
[ 0 == `grep "^cache-size" $dnscfg|wc -l` ] && echo cache-size=1000 >> $dnscfg
[ 0 == `grep "^no-resolv" $dnscfg|wc -l` ] && echo no-resolv >> $dnscfg
[ 0 == `grep "^server" $dnscfg|wc -l` ] && echo server=$public_dns >> $dnscfg
echo "change dnsmasq config ok"

#add auto start
sed -i "s/^exit 0//" /etc/rc.local
[ 0 == `grep shadowsocksr /etc/rc.local|wc -l` ] && echo /etc/init.d/shadowsocksr start >> /etc/rc.local
echo exit 0 >> /etc/rc.local
echo "add auto start ok"

#start service
[ `/etc/init.d/shadowsocksr status|grep "is running"|wc -l` -gt 0 ] && /etc/init.d/shadowsocksr stop
/etc/init.d/shadowsocksr start
