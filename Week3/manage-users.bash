#!/bin/bash

# storyline: Script to Add and Delete VPN peers

while getopts 'hdacu:' OPTION; do
case "$OPTION" in
	d) u_del=${OPTION}
	;;
	a) u_add=${OPTION}
	;;
	c) u_check=${OPTION}
	;;
	u) t_user=${OPTARG}
	;;
	h)

		echo ""
		echo "Usage $(basename $0) [-a]|[-d]|[-c] -u username"
		echo ""
		exit 1
	;;
	*)
		echo "Invalid value."
		exit 1
	;;
esac
done

# This will check if the "-a" and "-d" options are empty and throw an error if they are
if [[ (${u_del} == "" && ${u_add} == "" && ${u_check} == "") ]]
then
	echo "Please specify -a or -d or -c and the -u with a username."
fi

# Check to ensure "-u" is specified

if [[ (${u_del} != "" || ${u_add} != "") && ${t_user} == "" ]]
then
	echo "Please specify a user (-u)!"
	echo "Usage: $(basename $0) [-a][-d][-c] -u username"
	exit 1
fi

# Check if a user exist in wg0.conf
if [[ ${u_check} ]]
then
	if grep -q "# ${t_user}-wg0.conf begin" wg0.conf; then
		echo "[+] User ${t_user} found in wg0.conf."
	else
		echo "[-] User ${t_user} not found in wg0.conf."
	fi
fi

# Delete a User
if [[ ${u_del} ]]
then
	echo "[+] Deleting user..."
	sed -i "/# ${t_user}-wg0.conf begin/,/# ${t_user} end/d" wg0.conf
fi
