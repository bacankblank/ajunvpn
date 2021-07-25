#!/bin/bash
# Proxy For Edukasi & Imclass
# ==============================

# Getting Proxy Template
wget -q -O /usr/local/bin/edu-ovpn https://raw.githubusercontent.com/bokir-tampan/ranjau-darat/main/edu-ovpn.py
chmod +x /usr/local/bin/edu-ovpn

# Installing Service
cat > /etc/systemd/system/edu-ovpn.service << END
[Unit]
Description=Python Edu ovpn By bokirtampan
Documentation=https://bokirtampan.xyz
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python -O /usr/local/bin/edu-ovpn 2082
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable edu-ovpn
systemctl restart edu-ovpn

clear
