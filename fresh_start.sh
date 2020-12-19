#!/usr/bin/env bash

# initialize options
Development='false'
CTFpentest='false'
Help='false'
HashCrackServer='false'
Initial='false'

while getopts ':d:c:h:s:i' 'OPTARG'; do
  case ${OPTARG} in
    'd') Development='true';;
    'c') CTFpentest='true';;
    'h') Help='true';;
    's') HashCrackServer='true';;
    'i') Initial='true';;
  esac
done

if [ "$Development" = false ] && [ "$CTFpentest" = false ] && [ "$HashCrackServer" = false ] && [ "$Initial" = false ]; then
	Help='true'
fi

if [ "$Help" = true ]; then
    echo 'Options are:'
    echo '    -d for development'
    echo '    -c for CTF/pentest'
    echo '    -h for help'
    echo '    -s for dedicated hashcat setup (Not implemented yet)'
    echo '    -i for initial or default setup'
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

# Initial or default provisioning 
if [ "$Initial" = true ]; then

	BLUE "Updating repositories..."
	sudo apt update

	BLUE "Upgrading system..."
	sudo apt upgrade -y

	BLUE "Setting up zsh..."
	wget "https://raw.githubusercontent.com/bnsmcx/dotfiles/main/.zshrc"
	sudo apt install -y zsh
	chsh -s $(which zsh)

	BLUE "Installing guake..."
	sudo apt install -y guake

	BLUE "Installing VIM..."
	sudo apt install -y vim

	BLUE "Installing tree..."
	sudo apt install -y tree

	BLUE "Installing git..."
	sudo apt install -y git

	BLUE "Installing curl..."
	sudo apt install -y curl

	BLUE "Installing Signal..."
	# 1. Install our official public software signing key
	wget -O- https://updates.signal.org/desktop/apt/keys.asc |\
	  sudo apt-key add -

	# 2. Add our repository to your list of repositories
	echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" |\
	  sudo tee -a /etc/apt/sources.list.d/signal-xenial.list

	# 3. Update your package database and install signal
	sudo apt update && sudo apt install -y signal-desktop

	BLUE "Installing pip..."
	sudo apt-get install -y python-pip
	sudo apt install -y python3-pip

	BLUE "Removing boilerplate home directories..."
	rmdir /home/*/Documents /home/*/Music /home/*/Pictures /home/*/Public /home/*/Templates /home/*/Videos

	BLUE "Installing openvpn..."
	sudo apt-get install -y openvpn

	BLUE "Installing pinta..."
	sudo apt-get install -y pinta

	BLUE "VirtualBox..."
	sudo apt-get install -y virtualbox

	BLUE "Installing Joplin..."
	wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash

fi

# Provisioning for development
if [ "$Development" = true ]; then
	# stuff to install
	GREEN 'Provisioning for development...'

	BLUE 'Installing Java JDK and JRE...'
	sudo apt install -y default-jdk
	sudo apt install -y default-jre

	BLUE 'Installing Intellij IDEA...'
	sudo apt install -y snapd
	# add /snap/bin to PATH
	echo "PATH=/snap/bin:$PATH" >> $HOME/.profile
	sudo snap install intellij-idea-community --classic
	export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/snapd/desktop"
	export PATH=/snap/bin:$PATH
	echo "export PATH=/snap/bin:$PATH" >> ~/.zshrc
	echo "export XDG_DATA_DIRS=$XDG_DATA_DIRS:/var/lib/snapd/desktop" >> ~/.zshrc

fi


# Provisioning for CTF/Pentesting
if [ "$CTFpentest" = true ]; then
	# stuff to install
	GREEN 'Provisioning for CTF/Pentesting...'

	BLUE 'Installing docker...'
	sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
	sudo apt update
	apt-cache policy docker-ce
	sudo apt install -y docker-ce
	sudo usermod -aG docker ${USER}

	BLUE 'Pulling the parrot/security docker image...'
	mkdir $HOME/parrot
	docker pull parrotsec/security

	RED 'Log out and then back in for addition of user to docker group to take effect...'

fi
