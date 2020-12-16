#!/usr/bin/env bash

# initialize options
Development='false'
CTFpentest='false'
Help='false'
HashCrackServer='false'

while getopts ':d:c:h:' 'OPTARG'; do
  case ${OPTARG} in
    'd') Development='true';;
    'c') CTFpentest='true';;
    'h') Help='true';;
    's') HashCrackServer='true';;
  esac
done

if [ "$Help" = true ]; then
    echo 'Options are:'
    echo '    -d for development'
    echo '    -c for CTF/pentest'
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
wget -O - https://raw.githubusercontent.com/laurent22/joplin/master/Joplin_install_and_update.sh | bash --allow-root

BLUE "Installing xclip..."
sudo apt install -y xclip
grep "alias xclip" ~/.bashrc
if [ $? -eq 1 ]
then
	echo "alias xclip='xclip -selection clipboard'" >> ~/.bashrc
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

	BLUE "Installing princeprocessor..."
	sudo apt install -y princeprocessor

    BLUE "Getting LinEnum.sh..."
	wget -O ~/scripts/LinEnum.sh "https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh"

	BLUE "Getting linpeas.sh..."
	wget -O ~/scripts/linpeas.sh "https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/raw/master/linPEAS/linpeas.sh"

	BLUE "Installing steghide..."
	sudo apt install -y steghide

	BLUE "Installing zsteg..."
	sudo apt install -y ruby
	sudo gem install zsteg

	BLUE "Installing exiftool..."
	sudo apt install -y exiftool

	BLUE "Installing stegoveritas..."
	pip3 install stegoveritas
	sudo apt install -y libimage-exiftool-perl
	sudo apt install -y libexempi*
	sudo apt install -y p7zip-full
	sudo apt install -y foremost
	sudo apt install -y steghide
	echo "# Add .local/bin to PATH"
	echo "export PATH=~/.local/bin:$PATH" >> ~/.bashrc

	BLUE "Installing sonic-visualizer..."
	sudo apt install -y sonic-visualiser

	BLUE "Installing ghidra..."
	wget "https://www.ghidra-sre.org/ghidra_9.1.2_PUBLIC_20200212.zip"
	unzip ghidra_9.1.2_PUBLIC_20200212.zip
	rm ghidra_9.1.2_PUBLIC_20200212.zip
	echo "# add ghidra to the path" >> ~/.bashrc
	echo "export PATH=/home/daisy/ghidra_9.1.2_PUBLIC:$PATH" >> ~/.bashrc

	BLUE "Installing pwncat..."
	pip3 install git+https://github.com/calebstewart/pwncat.git

	BLUE "Installing gobuster..."
	sudo apt install gobuster

fi
