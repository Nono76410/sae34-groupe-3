#!/bin/bash
set -e

CERT_DIR="/etc/openvpn/certs"
EASYRSA_DIR="/opt/easyrsa"

echo "=== Generating OpenVPN Certificates ==="

# Initialiser EasyRSA
mkdir -p "$EASYRSA_DIR"
cd "$EASYRSA_DIR"

# Copier les fichiers d'EasyRSA
cp -r /usr/share/easy-rsa/* . 2>/dev/null || true

# Initialiser PKI
./easyrsa init-pki >/dev/null 2>&1 || echo "PKI already initialized"

# Générer l'autorité de certification
echo "Generating CA..."
./easyrsa build-ca nopass <<<$(echo -e "\n") >/dev/null 2>&1

# Générer le certificat serveur
echo "Generating Server Certificate..."
./easyrsa gen-req vpn-server nopass <<<$(echo -e "\n") >/dev/null 2>&1
./easyrsa sign-req server vpn-server nopass <<<$(echo -e "yes\n") >/dev/null 2>&1

# Générer les clés Diffie-Hellman
echo "Generating DH parameters..."
./easyrsa gen-dh >/dev/null 2>&1

# Générer la clé TLS
echo "Generating TLS-Auth key..."
openvpn --genkey --secret ta.key

# Copier les certificats dans le bon répertoire
echo "Copying certificates..."
cp pki/ca.crt "$CERT_DIR/"
cp pki/issued/vpn-server.crt "$CERT_DIR/server.crt"
cp pki/private/vpn-server.key "$CERT_DIR/server.key"
cp pki/dh.pem "$CERT_DIR/"
cp ta.key "$CERT_DIR/"

# Vérifier que tous les fichiers existent
echo "Verifying certificates..."
for file in ca.crt server.crt server.key dh.pem ta.key; do
  if [ -f "$CERT_DIR/$file" ]; then
    echo "✓ $file created successfully"
  else
    echo "✗ Error: $file not found!"
    exit 1
  fi
done

echo "=== Certificates generated successfully ==="
ls -lh "$CERT_DIR/"
