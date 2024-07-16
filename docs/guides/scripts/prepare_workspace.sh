#!/bin/bash

error_message() {
  echo -e "\e[31mError: $1\e[0m"
  exit 1
}

cd $HOME
mkdir workspace
cd workspace

if [ ! -d "sonic-platform-vpp" ]; then
  echo "Directory 'sonic-platform-vpp' not found. Cloning the repository..."
  git clone https://github.com/PANTHEONtech/sonic-platform-vpp.git || error_message "Failed to clone the repository."
fi

if [ ! -d "dev" ]; then
  echo "Directory 'dev' not found. Cloning the repository..."
  git clone https://github.com/PANTHEONtech/sonic-platform-vpp.git dev || error_message "Failed to clone the repository."
fi

if [ ! -d "backups" ]; then
  echo "Directory 'backups' not found. Creating the directory..."
  mkdir backups
fi