#!/bin/bash

echo -e " Pleace Insert Your Domain"
read -p "Domain : " domain
echo $domain > /root/domain

domain=$(cat /root/domain)

apt update
sudo add-apt-repository ppa:ondrej/nginx
apt install nginx curl  openssl netcat -y
sudo apt install python3-certbot-nginx
rm -f /etc/nginx/conf.d/default.conf

#install v2ray
apt install iptables iptables-persistent -y
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion ntpdate -y
ntpdate pool.ntp.org
apt -y install chrony
timedatectl set-ntp true
systemctl enable chronyd && systemctl restart chronyd
systemctl enable chrony && systemctl restart chrony
timedatectl set-timezone Asia/Jakarta
chronyc sourcestats -v
chronyc tracking -v
date
systemctl stop nginx

# install v2ray
wget https://raw.githubusercontent.com/bokir-tampan/ranjau-darat/main/go.sh && chmod +x go.sh && ./go.sh
rm -f /root/go.sh
mkdir /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/v2ray/v2ray.crt --keypath /etc/v2ray/v2ray.key --ecc
chown www-data.www-data /etc/v2ray/v2ray.*
service squid start
cat >/etc/nginx/conf.d/v2ray.conf <<EOF
    server {
        listen 80;
        listen [::]:80;
        listen 443 ssl http2 reuseport;
        listen [::]:443 http2 reuseport;
        ssl_certificate       /etc/v2ray/v2ray.crt;
        ssl_certificate_key   /etc/v2ray/v2ray.key;
        ssl_protocols         TLSv1.3;
        ssl_ciphers           TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
        
        # Config for 0-RTT in TLSv1.3
        ssl_early_data on;
        ssl_stapling on;
        ssl_stapling_verify on;
        add_header Strict-Transport-Security "max-age=31536000";
        }
EOF
sed -i '$ ilocation /v2ray' /etc/nginx/conf.d/v2ray.conf
sed -i '$ i{' /etc/nginx/conf.d/v2ray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/v2ray.conf
sed -i '$ iproxy_pass http://127.0.0.1:10000;' /etc/nginx/conf.d/v2ray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/v2ray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/v2ray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/v2ray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/v2ray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/v2ray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/v2ray.conf
sed -i '$ iproxy_set_header Early-Data \$ssl_early_data;' /etc/nginx/conf.d/v2ray.conf
sed -i '$ i}' /etc/nginx/conf.d/v2ray.conf

uuid=$(cat /proc/sys/kernel/random/uuid)
cat> /etc/v2ray/config.json << END
{
  "log": {
        "access": "/var/log/v2ray/access.log",
        "error": "/var/log/v2ray/error.log",
        "loglevel": "warning"
    },
  "inbounds": [
    {
    "port":10000,
      "listen": "127.0.0.1",
      "tag": "vmess-in",
      "protocol": "vmess",
      "settings": {
        "clients": [
        {
            "id": "${uuid}",
            "alterId": 2
#tls
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path":"/v2ray"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": { },
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "settings": { },
      "tag": "blocked"
    }
  ],
  "dns": {
    "servers": [
      "https+local://1.1.1.1/dns-query",
          "1.1.1.1",
          "1.0.0.1",
          "8.8.8.8",
          "8.8.4.4",
          "localhost"
    ]
  },
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "inboundTag": [
          "vmess-in"
        ],
        "outboundTag": "direct"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  }
}
END
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 443 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload
systemctl daemon-reload
systemctl restart v2ray
systemctl enable v2ray
/usr/sbin/nginx -t && systemctl restart nginx
cd /usr/bin
wget -O addws "https://raw.githubusercontent.com/bacankblank/ajunvpn/main/addws.sh"
chmod +x addws
mv /root/domain /etc/v2ray
