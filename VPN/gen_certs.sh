#!/bin/bash

# Script de génération des certificats OpenVPN

set -e

CERT_DIR="certs"

# Créer le répertoire s'il n'existe pas
mkdir -p "$CERT_DIR"

echo "🔐 Génération des certificats OpenVPN..."

# 1. Générer la clé CA
echo "1️⃣  Génération de la CA..."
openssl genrsa -out "$CERT_DIR/ca.key" 2048

# 2. Générer le certificat CA
echo "2️⃣  Génération du certificat CA..."
openssl req -new -x509 -days 365 -key "$CERT_DIR/ca.key" -out "$CERT_DIR/ca.crt" \
    -subj "/C=FR/ST=IDF/L=Paris/O=LAB/CN=ca.lab.local"

# 3. Générer la clé serveur
echo "3️⃣  Génération de la clé serveur..."
openssl genrsa -out "$CERT_DIR/server.key" 2048

# 4. Générer la demande de signature de certificat serveur
echo "4️⃣  Génération du CSR serveur..."
openssl req -new -key "$CERT_DIR/server.key" -out "$CERT_DIR/server.csr" \
    -subj "/C=FR/ST=IDF/L=Paris/O=LAB/CN=vpn.lab.local"

# 5. Signer le certificat serveur avec la CA
echo "5️⃣  Signature du certificat serveur..."
openssl x509 -req -days 365 -in "$CERT_DIR/server.csr" \
    -CA "$CERT_DIR/ca.crt" -CAkey "$CERT_DIR/ca.key" -CAcreateserial \
    -out "$CERT_DIR/server.crt"

# 6. Générer les paramètres Diffie-Hellman
echo "6️⃣  Génération des paramètres DH (cela peut prendre du temps)..."
openssl dhparam -out "$CERT_DIR/dh.pem" 2048

# 7. Générer une clé ta.key pour tls-auth (optionnel mais recommandé)
echo "7️⃣  Génération de la clé ta..."
openssl rand -hex 32 > "$CERT_DIR/ta.key"

# Permissions
chmod 600 "$CERT_DIR/server.key"
chmod 600 "$CERT_DIR/ca.key"
chmod 644 "$CERT_DIR/ca.crt"
chmod 644 "$CERT_DIR/server.crt"
chmod 644 "$CERT_DIR/dh.pem"
chmod 600 "$CERT_DIR/ta.key"

# Nettoyer le CSR
rm -f "$CERT_DIR/server.csr" "$CERT_DIR/ca.srl"

echo "✅ Certificats générés avec succès dans le répertoire $CERT_DIR/"
echo ""
echo "📋 Fichiers créés:"
ls -lh "$CERT_DIR/"
