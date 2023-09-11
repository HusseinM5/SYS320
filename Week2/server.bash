#!/bin/bash

# StoryLine: Script to configure/create Wireguard Server


# Server Config variable
ServerConfig="wg0.conf"

# Check for existing config file and if we want to overwrite them
if [[ -f "${ServerConfig}" ]]
then
	# Ask if we need to overwrite the file
	echo "[!] The file ${ServerConfig} already exists."
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


# Create a private key
privKey="$(wg genkey)"

# Create a public key
pubKey="$(echo ${privKey} | wg pubkey)"

# Set the addresses (in my case one address)
addresses="10.254.132.0/24"

# Set server address
ServerAddress="10.254.132.1/24"

# Set the listening port
lport="4282"

# Creating client format configuration
peerInfo="# ${addresses} 192.168.241.131:4282 ${pubKey} 8.8.8.8,1.1.1.1 1280 120 0.0.0.0/0"

echo "${peerInfo}
[Interface]
Address = ${ServerAddress}
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ens33 -j MASQUERADE
ListenPort = ${lport}
PrivateKey = ${privKey}
" > wg0.conf 
