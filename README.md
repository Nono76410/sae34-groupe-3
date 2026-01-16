# SAE34 - Infrastructure Réseau Sécurisée avec Docker

Déploiement complet d'une infrastructure réseau de laboratoire utilisant Docker Compose avec DNS, NTP et VPN.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│         Docker Network: lab_net (172.28.0.0/24)        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  NTP Server        DNS Server        VPN Server         │
│  172.28.0.4        172.28.0.5        172.28.0.2         │
│  Port 20123/UDP    Port 20053/UDP    Port 21194/UDP     │
│  (Chrony)          (BIND9)           (OpenVPN)          │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Services

### 1. **NTP (Network Time Protocol)** - Chrony
- **Conteneur** : ntp_server
- **Port** : 20123/UDP
- **IP réseau** : 172.28.0.4
- **Configuration** : `NTP/chrony.conf`
- **Rôle** : Synchronise l'heure de tous les services

### 2. **DNS (Domain Name System)** - BIND9
- **Conteneur** : dns_server
- **Port** : 20053/UDP + 20053/TCP
- **IP réseau** : 172.28.0.5
- **Zone** : lab.local
- **Enregistrements** :
  - ns.lab.local → 172.28.0.5
  - vpn.lab.local → 172.28.0.2
  - ntp.lab.local → 172.28.0.4
  - radius.lab.local → 172.28.0.3
  - dns.lab.local → 172.28.0.5
- **Rôle** : Résout les noms de domaine du réseau lab

### 3. **VPN (Virtual Private Network)** - OpenVPN
- **Conteneur** : vpn_server
- **Port** : 21194/UDP (externe) → 1194/UDP (interne)
- **IP réseau** : 172.28.0.2
- **Réseau VPN clients** : 10.8.0.0/24
- **Configuration** : `VPN/server.conf`
- **Sécurité** :
  - Chiffrement : AES-256-CBC
  - Authentification : SHA256
  - Certificats auto-signés générés automatiquement
- **Rôle** : Permet une connexion chiffrée au réseau de gestion

## Installation et démarrage

### Prérequis
- Docker Desktop (Windows) ou Docker (Linux)
- Docker Compose >= 1.29
- PowerShell (Windows) ou Bash (Linux/Mac)

### Démarrer les services

```powershell
# Se placer dans le répertoire du projet
cd sae34-groupe-3

# Démarrer tous les conteneurs
docker compose up -d --build
```

## Tests de validation

### 1. Vérifier les conteneurs

```powershell
docker ps
# Doit afficher : ntp_server, dns_server, vpn_server - tous UP
```

### 2. Tester le DNS

```powershell
# Depuis Windows
nslookup ntp.lab.local 127.0.0.1

# Depuis un conteneur
docker exec dns_server dig @localhost ntp.lab.local
```

### 3. Tester le NTP

```powershell
docker exec ntp_server chronyc sources
```

### 4. Tester le VPN

```powershell
# Vérifier l'écoute sur le port UDP 1194
docker exec vpn_server ss -ulnp | grep 1194

# Affichage attendu:
# UNCONN 0 0 0.0.0.0:1194 0.0.0.0:*
```

### 5. Vérifier les logs

```powershell
# DNS
docker logs dns_server

# NTP
docker logs ntp_server

# VPN
docker logs vpn_server
```

## Structure des fichiers

```
.
├── docker-compose.yml          # Configuration Docker Compose
├── README.md                    # Ce fichier
├── DNS/
│   ├── dockerfile
│   └── config/
│       ├── db.lab.local        # Zone DNS
│       ├── named.conf.local    # Config locale
│       └── named.conf.options  # Options générales
├── NTP/
│   ├── dockerfile
│   └── chrony.conf             # Config NTP
└── VPN/
    ├── dockerfile
    ├── server.conf             # Config serveur OpenVPN
    ├── entrypoint.sh          # Script de démarrage
    ├── gen_certs.ps1          # Script génération certificats (Windows)
    └── gen_certs.sh           # Script génération certificats (Linux)
```

## Troubleshooting

### Le VPN ne démarre pas
```powershell
docker logs vpn_server
```
Cherchez "Initialization Sequence Completed" ou des erreurs de certificats.

### Le DNS ne résout pas les noms
```powershell
docker logs dns_server | grep "zone lab.local"
```
Doit afficher "zone lab.local/IN: loaded serial 2"

### Le conteneur NTP s'arrête
```powershell
docker logs ntp_server
```
Vérifiez que la privilège SYS_TIME est accordé et que le port 20123 n'est pas déjà utilisé.

## Sécurité

⚠️ **Attention** : Cette configuration est destinée à un **laboratoire d'apprentissage** uniquement.

- Les certificats VPN sont auto-signés
- Les interfaces réseau doivent être sécurisées en production
- Utilisez des certificats valides pour la production

## Ressources

- [OpenVPN Documentation](https://openvpn.net/community-downloads/)
- [BIND9 Documentation](https://www.isc.org/bind/)
- [Chrony Documentation](https://chrony.tuxfamily.org/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
