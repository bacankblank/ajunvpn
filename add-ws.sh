#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- ifconfig.me/ip);
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10 )
City=$(curl -s ipinfo.io/city)
echo "Checking VPS"
IZIN=$( curl http://lnd.red-flat.my.id:81/shahwjusisjsnajakajannaiajanajam | grep $MYIP )
if [ $MYIP = $IZIN ]; then
echo -e "${green}Permission Accepted...${NC}"
else
echo -e "${red}Permission Denied!${NC}";
echo "Only For Premium Users"
exit 0
fi
clear
source /var/lib/premium-script/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/v2ray/domain)
else
domain=$IP
fi
tls="$(cat ~/log-install.txt | grep -w "Vmess TLS" | cut -d: -f2|sed 's/ //g')"
none="$(cat ~/log-install.txt | grep -w "Vmess None TLS" | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "User: " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/v2ray/config.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			exit 1
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#tls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"2"',"email": "'""$user""'"' /etc/v2ray/config.json
sed -i '/#none$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"2"',"email": "'""$user""'"' /etc/v2ray/none.json
cat>/etc/v2ray/$user-tls.json<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "${tls}",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/v2ray",
      "type": "none",
      "host": "bug.com",
      "tls": "tls"
}
EOF
cat>/etc/v2ray/$user-none.json<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "bug.com",
      "port": "${none}",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/v2ray",
      "type": "none",
      "host": "${domain}",
      "tls": "none"
}
EOF
vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmess_base642=$( base64 -w 0 <<< $vmess_json2)
vmesslink1="vmess://$(base64 -w 0 /etc/v2ray/$user-tls.json)"
vmesslink2="vmess://$(base64 -w 0 /etc/v2ray/$user-none.json)"
systemctl restart v2ray
systemctl restart v2ray@none
service cron restart
clear
echo -e ""
echo -e "==============-VMESS-=============="
echo -e "Remarks        : ${user}"
echo -e "Domain         : ${domain}"
echo -e "ISP            : ${ISP}"
echo -e "City           : ${City}"
echo -e "=============-Main Port-============="
echo -e "Port TLS       : ${tls}"
echo -e "Port none TLS  : ${none}"
echo -e "==================================="
echo -e "ID             : ${uuid}"
echo -e "AlterId        : 0"
echo -e "Security       : auto"
echo -e "Network        : ws"
echo -e "Path           : /v2ray"
echo -e "Expired On     : $exp"
echo -e "==================================="
echo -e "Link HTTPS ${tls} : ${vmesslink1}"
echo -e "==================================="
echo -e "Link HTTP ${none} : ${vmesslink2}"
echo -e "==================================="
echo -e "Script Modified By     : AjunVPN"
