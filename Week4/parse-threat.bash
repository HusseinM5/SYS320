#!/bin/bash

# Storyline: Extract IPs from emergingthreats.net and create a firewall ruleset

# emerging-drop.suricata.rules file
Threatfile="/tmp/emerging-drop.suricata.rules"

# Regex to extract the networks (2.57.234.0/23)
function creat_badIPs(){

	# read the emerging-drop.suricata.rules file to organize it and create the badips.txt file
	echo "[+] Creating badips.txt file based of emerging-drop.suricata.rules"
	egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0/[0-9]{1,2}' /tmp/emerging-drop.suricata.rules | sort -u | tee badips.txt

}


# Download emerging-drop.suricata.rules and check if they exist
function Download_rules() {

if [[ -f "${Threatfile}" ]]

then
	# Ask if we need to overwrite the file
	echo "[!] The file ${Threatfile} already exists."
	echo -n "[!] Do you want to overwrite it? [y|n]"
	read opt_overwrite
	if [[ "$opt_overwrite" == "n" || "$opt_overwrite" == "N" || "$opt_overwrite" == "" ]]
	then
		# Creating badIPs.txt based on the existed file
		creat_badIPs
	elif [[ "$opt_overwrite" == "y" || "$opt_overwrite" == "Y" ]]
	then
		# Download the emerging-drop.suricata.rules file and save it into the tmp directory
		echo "[+] Overwriting /tmp/emerging-drop.suricata.rules"
		wget https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules -O /tmp/emerging-drop.suricata.rules

		# Creating badIPs.txt
		creat_badIPs
	else
		echo "[-] Invalid input"
		exit 1
	fi
fi

}

Download_rules

# Creating inbound drop rule for the firewall based on the user requested switch

while getopts 'icwmp' OPTION ; do
	case "$OPTION" in
		i) iptables=${OPTION}
		;;
		c) cisco=${OPTION}
		;;
		w) WindowsFirewall=${OPTION}
		;;
		m) macOS=${OPTION}
		;;
		p) CiscoParser=${OPTION}
		;;
		*)
			echo "Invalid Value"
			exit 1
		;;

	esac
done

# If iptables requested
if [[ ${iptables} ]]; then
	for eachip in $(cat badips.txt); do
		echo "iptables -A INPUT -s ${eachip} -j DROP" | tee -a badips_iptables.txt
	done
	clear
	echo "Created firewall drop rules in file (badips_iptables.txt)"
fi

# If cisco requested
if [[ ${cisco} ]]; then
	egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0' badips.txt | tee badips_nocidr.txt
	for eachip in $(cat badips_nocidr.txt); do
		echo "deny ip host ${eachip} any" | tee -a badips_cisco.txt
	done
	rm badips_nocidr.txt
	clear
	echo "Created firewall drop rules in file (badips_cisco.txt)"
fi

# If Windows requested
if [[ ${WindowsFirewall} ]]; then
	egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0' badips.txt | tee badips_windowsformat.txt
	for eachip in $(cat badips_windowsformat.txt); do
		echo "netsh advfirewall firewall add rule name=\"BLOCK IP ADDRESS - ${eachip}\" dir=in action=block remoteip=${eachip}" | tee -a badips_WinNetsh.txt
	done
	rm badips_windowsformat.txt
	clear
	echo "Created firewall drop rules in file (badips_WinNetsh.txt)"
fi

# If MacOS requested
if [[ ${macOS} ]]; then
	echo 'scrub-anchor "com.apple/*" nat-anchor "com.apple/*" rdr-anchor "com.apple/*" dummynet-anchor "com.apple/*" anchor "com.apple/*" load anchor "com.apple" from "/etc/pf.anchors/com.apple"' | tee -a MAC.conf
	sleep 2
	for eachip in $(cat badips.txt); do
		echo "block in from ${eachip} to any" | tee -a MAC.conf
	done

	clear
	echo "Created IP tables for firewall drop rules in file (MAC.conf)"
fi

# If Cisco Parser requested
if [[ ${CiscoParser} ]]; then
	wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/targetedthreats.csv
	echo "class-map match-any BAD_URLS" > ciscothreats.txt
	awk -F, '/"domain"/ {gsub(/"/, "", $2); print "match protocol http host \"" $2 "\""}' /tmp/targetedthreats.csv | sort -u >> ciscothreats.txt
	clear
	echo "Cisco URL filters file successfully created at (ciscothreats.txt)"
fi

