#!/bin/bash
set -e

echo "Preparing OpenVPN..."
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
  mknod /dev/net/tun c 10 200 2>/dev/null || true
fi
chmod 666 /dev/net/tun

echo "TUN device ready"
echo "Starting OpenVPN server on 1194/udp..."

# Afficher les premiers fichiers de certificat pour vérification
ls -lh /etc/openvpn/certs/

exec openvpn --config /etc/openvpn/server.conf --verb 4

