#!/usr/bin/bash
#shopt -s expand_aliases

# initialize options
auto_secure='false'
show_help='false'
quarantine='false'
set_passwords='false'
lock_firewall='false'
set_interfaces='false'

# initialize argument variables
new_password='who let the dogs out'
target_user=''

while getopts ':p:dhq:fi' option; do
  case "$option" in
	'p')
	    set_passwords='true'
	    new_password=${OPTARG}
	    ;;
    	'd') auto_secure='true';;
    	'h') show_help='true';;
    	'q')
	    quarantine='true'
	    target_user=${OPTARG}
	    ;;
    	'f') lock_firewall='true';;
    	'i') set_interfaces='true';;
  esac
done

if [ "$auto_secure" = false ] && [ "$quarantine" = false ] && [ "$set_passwords" = false ] && [ "$lock_firewall" = false ] && [ "$set_interfaces" = false ]; then
	show_help='true'
fi

if [ "$show_help" = true ]; then

    echo ''
    echo 'Options are:'
    echo ''
    echo '    -p set_passwords    -- sets every user'\'s' password: "sudo ccdc-linux.sh -p newP@ssw0rd"'
    echo '    -d auto_secure      -- default initial securing of the system'
    echo '    -h show_help        -- this'
    echo '    -q quarantine       -- moves all files owned by a user into their home directory and then zips it: "sudo ccdc-linux.sh -q user"'
    echo '    -f lock_firewall    -- completely locks down the firewall, all services will be affected'
    echo '    -i set_interfaces   -- quickly sets all interfaces up/down: "sudo ccdc-linux.sh -i down" -or- "sudo ccdc -i down"'
fi

# Define colors...
RED=`tput bold && tput setaf 1`
GREEN=`tput bold && tput setaf 2`
YELLOW=`tput bold && tput setaf 3`
BLUE=`tput bold && tput setaf 4`
NC=`tput sgr0`

function RED(){
	echo -e "\n${RED}${1}${NC}"
}
function GREEN(){
	echo -e "\n${GREEN}${1}${NC}"
}
function YELLOW(){
	echo -e "\n${YELLOW}${1}${NC}"
}
function BLUE(){
	echo -e "\n${BLUE}${1}${NC}"
}

# Testing if root...
if [ $UID -ne 0 ]
then
	RED "You must run this script as root!" && echo
	exit
fi

# set passwords for all users on the system
if [ "$set_passwords" = true ]; then
	BLUE "Setting all user passwords to $new_password..."
	cat /etc/passwd | cut -d":" -f1 | xargs -I % echo %:$new_password | sudo chpasswd
fi

# auto_secure performs all default actions to lock down the box 
if [ "$auto_secure" = true ]; then
	BLUE 'Test trigger $auto_secure'
fi

# Move all files owned by a user to their home directory and zip it
if [ "$quarantine" = true ]; then
	BLUE "Quarantining $target_user..."
	echo $target_user | xargs -I % sh -c 'find / -type f -user % -exec mv {} /home/% \; && zip -r /home/%.zip /home/% && rm -r /home/%'
fi

# Completely lock down the firewall, this will interrupt all services
if [ "$lock_firewall" = true ]; then
	BLUE 'Test trigger $lock_firewall'
fi

# Set all interfaces either up or down
if [ "$set_interfaces" = true ]; then
	BLUE 'Test trigger $set_interfaces'
fi
