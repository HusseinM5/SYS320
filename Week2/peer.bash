#!/bin/bash

# Storyline: Create Wireguard peer VPN configuration file


# Ask for the peer's name
echo -n "What is the peer's name? "
read peer_name

# Store Filename
peerFile="${peer_name}-wg0.conf"

# Check for existing config file and if we want to overwrite them
if [[ -f "${peerFile}" ]]
then
	# Ask if we need to overwrite the file
	echo "[!] The file ${peerFile} already exists."
	echo -n "[!] Do you want to overwrite it? [y|n]"
	read opt_overwrite
	if [[ "$opt_overwrite" == "n" || "$opt_overwrite" == "N" || "$opt_overwrite" == "" ]]
	then
		echo "[-] Exiting..."
		exit 0
	elif [[ "$opt_overwrite" == "y" || "$opt_overwrite" == "Y" ]]
	then
		echo "[+] Creating Wireguard configuration file..."
	else
		echo "[-] Invalid input"
		exit 1
	fi
fi

# Generate a private key
privKey="$(wg genkey)"

# Generate a public key
pubKey="$(echo ${privKey} | wg pubkey)"

# Generate preshared key (for additional security)
preKey="$(wg genpsk)"

# 10.254.132.0/24,172.16.28.0/24  192.199.97.163:4282 NH9qUERcppInDrMp8aT5Lx3gPdwf6s980Msa7y1x9nE= 8.8.8.8,1.1.1.1 1280 120 0.0.0.0/0

# Endpoint
end="$(head -1 wg0.conf | awk ' { print $3 } ')"

# Server Public Key
pub="$(head -1 wg0.conf | awk ' { print $4 } ')"

# DNS Servers
dns="$(head -1 wg0.conf | awk ' { print $5 } ')"

# MTU
mtu="$(head -1 wg0.conf | awk ' { print $6 } ')"

# KeepAlive
keep="$(head -1 wg0.conf | awk ' { print $7 } ')"

# ListeningPort
lport="$(shuf -n1 -i 40000-50000)"

# Default routes for VPN
routes="$(head -1 wg0.conf | awk ' { print $8 } ')"

# Create peer configuration file
echo "[Interface]
Address = 10.254.132.100/24
DNS = ${dns}
ListenPort = ${lport}
MTU = ${mtu}
PrivateKey = ${privKey}
[Peer]
AllowedIPs = ${routes}
PersistentKeepalive = ${keep}
PresharedKey = ${preKey}
PublicKey = ${pubKey}
Endpoint = ${end}
" > ${peerFile}

# Add the peer configuration to the server configuration
echo "
# ${peerFile} begin
[Peer]
PublicKey = ${pubKey}
PresharedKey = ${preKey}
AllowedIPs = 10.254.132.100/32
# ${peer_name} end" | tee -a wg0.conf
