#!/bin/bash


# Define sexy terminal colors
RESET='\033[0m'
BCYAN='\033[0;96m'
GREEN='\033[0;32m'
RED='\033[0;91m'


# Download the main script from GitHub
wget -q -O /usr/local/bin/webt https://raw.githubusercontent.com/FAXES/webt/main/webt.sh

# Make the script executable
chmod +x /usr/local/bin/webt

# Ensure /usr/local/bin is in the PATH
if ! echo "$PATH" | grep -q "/usr/local/bin"; then
    echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
    source ~/.bashrc
fi

# Yay the script has downloaded / installed!
echo "${GREEN} ${RESET}"
