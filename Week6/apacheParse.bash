#!/bin/bash

# Storyline: Script to parse Apache log files and create firewall rules

APACHE_LOG="$1"

# Check if the file exists
if [[ ! -f ${APACHE_LOG} ]]
then
	echo "[-] (File not found) Please specify the path to an existing log file."
	exit 1
fi


# Looking for web scanners
sed -e 's/\[//g' -e 's/\"//g' ${APACHE_LOG} | \
egrep -i "test|shell|echo|passwd|select|phpmyadmin|setup|admin|w00t" | \
awk ' BEGIN { format = "%-15s %-20s %-7s %-6s %-10s %s\n"
		printf format, "IP", "Date", "Method", "Status", "Size", "URI"
		printf format, "--", "----", "------", "------", "----", "---" }
{ printf format, $1, $4, $6, $9, $10, $7 }'


# Extract IP addresses, sort them and remove any duplicates
function Extips() {
	cat ${APACHE_LOG} | awk '{print $1}' | sort -u | tee badIPs.txt
}

# Function creates iptables ruleset
function iptablesR() {
if [[ -f badIPs.txt ]]
then
	for FoundIP in $(cat badIPs.txt)
	do
		echo "iptables -A INPUT -s ${FoundIP} -j DROP" | tee -a badIPs.iptables
	done
else
	Extips
	for FoundIP in $(cat badIPs.txt)
	do 
		echo "iptables -A INPUT -s ${FoundIP} -j DROP" | tee -a badIPs.iptables
	done
fi
}

# Function creates Windows Powershell ruleset
function windowsR() {
	if [[ -f badIPs.txt ]]
	then
		for FoundIP in $(cat badIPs.txt) 
		do
			echo "New-NetFirewallRule -DisplayName \"Block $FoundIP\" -Direction Inbound -LocalPort Any -Protocol TCP -Action Block -RemoteAddress $FoundIP" | tee -a WindowsRules.ps1
		done
	else
		Extips
		for FoundIP in $(cat badIPs.txt)
		do
			echo "New-NetFirewallRule -DisplayName \"Block $FoundIP\" -Direction Inbound -LocalPort Any -Protocol TCP -Action Block -RemoteAddress $FoundIP" | tee -a WindowsRules.ps1
		done
	fi
}

# Call functions to create iptables ruleset
iptablesR

# Call function to create Windows ruleset
windowsR