
#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- ifconfig.me/ip);
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
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10 )
CITY=$(curl -s ipinfo.io/city )

source /var/lib/premium-script/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/v2ray/domain)
else
domain=$IP
fi
read -p "Username : " Login
read -p "Password : " Pass
read -p "Expired (hari): " masaaktif

IP=$(wget -qO- ifconfig.me/ip);
ssl="$(cat ~/log-install.txt | grep -w "Stunnel4" | cut -d: -f2)"
sqd="$(cat ~/log-install.txt | grep -w "Squid" | cut -d: -f2)"
ovpn="$(netstat -nlpt | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
ovpn2="$(netstat -nlpu | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
sleep 1
echo Ping Host
echo Cek Hak Akses...
sleep 0.5
echo Permission Accepted
clear
sleep 0.5
echo Membuat Akun: $Login
sleep 0.5
echo Setting Password: $Pass
sleep 0.5
clear
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e ""
echo -e "Full Account Info"
echo -e "SSH - OVPN & Websocket"
echo -e "Username       : $Login"
echo -e "Password       : $Pass"
echo -e "================================="
echo -e "Host          : $domain"
echo -e "IP               : $IP"
echo -e "ISP            : $ISP"
echo -e "City           : $CITY"
echo -e "============-Main Port-============"
echo -e "OpenSSH             : 22"
echo -e "Dropbear             : 109, 143"
echo -e "SSL/TLS              : $ssl"
echo -e "SSLH                    : 443"
echo -e "Port WS SSL       : 443"
echo -e "Port WS HTTP    : 2095"
echo -e "Port WS OVPN   : 2082"
echo -e "Badvpn                : 7100-7300"
echo -e "Port Squid          : $sqd"
echo -e "==========-OVPN Config-==========="
echo -e "OpenVPN TCP      : http://$IP:85/tcp.ovpn"
echo -e "OpenVPN UDP      : http://$IP:85/udp.ovpn"
echo -e "OpenVPN SSL      : http://$IP:85/ssl.ovpn"
echo -e "================================"
echo -e "PAYLOAD Websocket :"                                                          
echo -e "GET / HTTP/1.1[crlf]Host: $domain[crlf]Connection: Keep-Alive[crlf]Upgrade: websocket[crlf][crlf]"
echo -e "================================"
echo -e "Expired On             : $exp"
echo -e "Script Modifield By : AjunVPN"
