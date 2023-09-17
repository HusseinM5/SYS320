#!/bin/bash

# Storyline: Menu for Securit Admin Tasks


# A function that will return if user entered an invalid option
function invalid_opt() {

	echo ""
	echo "Invalid option"
	echo ""
	sleep 2
}

# The main menu function
function menu() {

	# clear the screen
	clear

	echo "[1] Security Admin Menu"
	echo "[2] Exit"
	read -p "Please enter a option above: " choice

	case "$choice" in

	1) SecAdmin_menu
	;;
	2) exit 0
	;;
	*)

		invalid_opt
		# Call the main menu
		menu
	;;
	esac

}

# A function for Securit Admin Menu
function SecAdmin_menu() {
	clear
	echo "[1] List Running Processes"
	echo "[2] List open Network Sockets"
        echo "[3] Check if any user besides root has a UID of 0"
	echo "[4] Check last 10 logged in users"
	echo "[5] Check current logged in users"
        echo "[6] Exit"
	read -p "Please enter a option above: " choice

	case "$choice" in

	1) ps -ef |less
        ;;
        2) netstat -an --inet |less
        ;;
        3) grep 'x:0:' /etc/passwd | less
        ;;
        4) last | head -n 10 | less
	;;
	5) w |less
	;;
	6) exit 0
	;;
	*)
		invalid_opt

		SecAdmin_menu
	;;
	esac

SecAdmin_menu
}


# Call the main menu
menu
