#!/usr/bin/bash
#shopt -s expand_aliases

# initialize options
auto_secure='false'
show_help='false'
quarantine='false'
set_passwords='false'
lock_firewall='false'
set_interfaces='false'
new_user='false'
validate_checksums='false'

# initialize argument variables
new_password='who let the dogs out'
target_user=''
new_interface_setting='down'
user=''

while getopts ':p:dhq:fi:u:v' option; do
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
    	'i') 
	    set_interfaces='true'
	    new_interface_setting=${OPTARG}
	    ;;
	'u')
	    new_user='true'
	    input=($OPTARG)
	    user=${input[0]}
	    new_password=${input[1]}
	    ;;
	'v') validate_checksums='true';;
  esac
done

if [ "$validate_checksums" = false ] && [ "$new_user" = false ] && [ "$auto_secure" = false ] && [ "$quarantine" = false ] && [ "$set_passwords" = false ] && [ "$lock_firewall" = false ] && [ "$set_interfaces" = false ]; then
	show_help='true'
fi

if [ "$show_help" = true ]; then

    echo ''
    echo 'Options are:'
    echo ''
    echo '    -p set_passwords       sets every user'\'s' password:  -p newP@ssw0rd'
    echo '    -d auto_secure         default initial securing of the system'
    echo '    -h show_help           this'
    echo '    -q quarantine          kills a user'\'s' processes and archives their files in /home:  -q user'
    echo '    -f lock_firewall       completely locks down the firewall, all services will be affected'
    echo '    -i set_interfaces      quickly sets all interfaces up/down:  -i up'
    echo '    -u new_user            adds a new user with provided password, note quotes:  -u "user password"'
    echo "    -v validate_checksums  Check to make sure checksums of critical files haven't changed"
    
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

	BLUE "Setting all user passwords to '$new_password'..."
	for user in $(cat /etc/passwd | cut -d":" -f1)
	do
		echo $user:$new_password | sudo chpasswd
	done
fi

# auto_secure performs all default actions to lock down the box 
if [ "$auto_secure" = true ]; then

	BLUE "Securing the system..."
fi

# Move all files owned by a user to their home directory and zip it
if [ "$quarantine" = true ]; then

	BLUE "Killing all of $target_user's processes..."
	pkill -9 -u `id -u $target_user`

	BLUE "Quarantining $target_user's files in /home/$target_user.tgz..." && echo
	echo 'making a folder to put the loot in...'
	mkdir /home/$target_user
	chown root:root /home/$target_user
	echo 'searching the filesystem for files owned by the user and moving them to the loot folder...'
	find / 2>/dev/null -type f -user $target_user -exec mv '{}' /home/$target_user \;
	find / 2>/dev/null -type d -user $target_user -delete
	echo 'archiving the loot folder...'
        tar -czvf /home/$target_user.tgz /home/$target_user
	echo 'removing the unarchived loot folder...'
        rm -r /home/$target_user

fi

# Completely lock down the firewall, this will interrupt all services
if [ "$lock_firewall" = true ]; then

	BLUE "Firewall locked down, all network traffic will be stopped..."
	iptable -F
	iptables -P INPUT DROP
	iptables -P OUTPUT DROP
	iptables -P FORWARD DROP
fi

# Set all interfaces either up or down
if [ "$set_interfaces" = true ]; then

	BLUE "Setting all interfaces '$new_interface_setting'"
	for interface in $(ip a | grep mtu | cut -d":" -f2)
	do
		sudo ip link set $interface $new_interface_setting
	done
fi

# Create a user with a password
if [ "$new_user" = true ]; then
	
	BLUE "Created user: '$user' with password: '$new_password'..."
	sudo useradd --groups sudo $user
	echo $user:$new_password | sudo chpasswd
fi

# Get the checksums for a list of files, compare to known hashes, alert user of differences
if [ "$validate_checksums" = true ]; then

	if test -f /root/reference_checksums; then
		BLUE "Comparing current checksums of critical files to those previously obtained..."
	else
		BLUE "Capturing initial checksums of critical files..."
	fi
	echo
	BLUE "The reference checksums are always stored at /root/reference_checksums" && echo

	# add critical files or directories to be checked here using absolute paths
	# wrapped in quotes and separated by a single space
	declare -a critical_items=("/etc" "/tmp")
	for item in "${critical_items[@]}"; 
	do
		for file in $(sudo find $item -type f)
		do
			temp_string="$file : $(cat $file | md5sum)"
			echo $temp_string >> current_checksums
		done
	done
	if test -f /root/reference_checksums; then
		RED "Checking for differences..." && echo
		diff -qs /root/reference_checksums current_checksums
		diff -y --suppress-common-lines /root/reference_checksums current_checksums
		rm current_checksums
	else
		mv current_checksums /root/reference_checksums
		GREEN "Successfully stashed the reference checksums in /root/reference_checksums" && echo
	fi
fi
