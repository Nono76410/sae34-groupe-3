# Script PowerShell de génération des certificats OpenVPN

$CERT_DIR = "certs"

# Créer le répertoire
if (!(Test-Path $CERT_DIR)) {
    New-Item -ItemType Directory -Path $CERT_DIR | Out-Null
}

Write-Host "Generation des certificats OpenVPN..." -ForegroundColor Green

# 1. Générer la clé CA
Write-Host "1. Generation de la CA..." -ForegroundColor Yellow
& openssl genrsa -out "$CERT_DIR/ca.key" 2048

# 2. Générer le certificat CA
Write-Host "2. Generation du certificat CA..." -ForegroundColor Yellow
& openssl req -new -x509 -days 365 -key "$CERT_DIR/ca.key" -out "$CERT_DIR/ca.crt" `
    -subj "/C=FR/ST=IDF/L=Paris/O=LAB/CN=ca.lab.local"

# 3. Générer la clé serveur
Write-Host "3. Generation de la clé serveur..." -ForegroundColor Yellow
& openssl genrsa -out "$CERT_DIR/server.key" 2048

# 4. Générer la demande de signature de certificat serveur
Write-Host "4. Generation du CSR serveur..." -ForegroundColor Yellow
& openssl req -new -key "$CERT_DIR/server.key" -out "$CERT_DIR/server.csr" `
    -subj "/C=FR/ST=IDF/L=Paris/O=LAB/CN=vpn.lab.local"

# 5. Signer le certificat serveur avec la CA
Write-Host "5. Signature du certificat serveur..." -ForegroundColor Yellow
& openssl x509 -req -days 365 -in "$CERT_DIR/server.csr" `
    -CA "$CERT_DIR/ca.crt" -CAkey "$CERT_DIR/ca.key" -CAcreateserial `
    -out "$CERT_DIR/server.crt"

# 6. Générer les paramètres Diffie-Hellman
Write-Host "6. Generation des parametres DH (cela peut prendre du temps)..." -ForegroundColor Yellow
& openssl dhparam -out "$CERT_DIR/dh.pem" 2048

# 7. Générer une clé ta.key pour tls-auth
Write-Host "7. Generation de la clé ta..." -ForegroundColor Yellow
& openssl rand -hex 32 | Out-File -FilePath "$CERT_DIR/ta.key" -Encoding ASCII

# Nettoyer les fichiers temporaires
Remove-Item -Path "$CERT_DIR/server.csr" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$CERT_DIR/ca.srl" -Force -ErrorAction SilentlyContinue

Write-Host "Certificats generes avec succes!" -ForegroundColor Green
Write-Host ""
Write-Host "Fichiers crees:" -ForegroundColor Cyan
Get-ChildItem -Path $CERT_DIR | Select-Object Name, @{Name="Size";Expression={"{0:N0} bytes" -f $_.Length}}
