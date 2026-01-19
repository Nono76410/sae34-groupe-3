#!/bin/bash

echo "Preparing OpenVPN..."
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
  mknod /dev/net/tun c 10 200 2>/dev/null || true
fi
chmod 666 /dev/net/tun

echo "TUN device ready"
echo "Starting OpenVPN server on 1194/udp..."
echo ""

# Lancer OpenVPN en background
openvpn --config /etc/openvpn/server.conf > /dev/null 2>&1 &

# Attendre que le fichier log soit créé
for i in {1..5}; do
  if [ -f /var/log/openvpn/openvpn.log ]; then
    break
  fi
  sleep 0.5
done

# Afficher les logs et garder le container vivant
tail -f /var/log/openvpn/openvpn.log

