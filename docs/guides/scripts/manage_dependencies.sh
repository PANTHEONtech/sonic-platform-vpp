#!/bin/bash

YELLOW="\e[33m"
RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

usage() {
  echo -e "${YELLOW}Usage: $0 --install | --uninstall | --help${RESET}"
  echo -e "${YELLOW}Options:${RESET}"
  echo -e "${YELLOW}  --install    Install the dependencies.${RESET}"
  echo -e "${YELLOW}  --uninstall  Uninstall the dependencies.${RESET}"
  echo -e "${YELLOW}  --help       Display this help message.${RESET}"
  exit 1
}

error_message() {
  echo -e "${RED}Error: $1. Use --help for more information.${RESET}"
  exit 1
}

check_command() {
  command -v "$1" >/dev/null 2>&1 || error_message "$1 command not found"
}

if [ "$#" -ne 1 ]; then
  error_message "Exactly one argument is required"
fi

install_dependencies() {
  # Update Ubuntu
  sudo apt-get update && sudo apt-get upgrade -y

  # Install SONiC-vpp platform prerequisites
  sudo apt-get install -y make automake autoconf python3-pip
  sudo pip3 install j2cli

  # Install Docker (taken from https://docs.docker.com/engine/install/ubuntu/)
  # Add Docker's official GPG key and repository
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Update package index and install Docker
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Add current user to the docker group
  sudo usermod -aG docker ${USER}

  echo -e "${YELLOW}You have to reboot the system for changes to take effect. Proceed? (yes/no)${RESET}"
  read -r response
  case "$response" in
    [yY][eE][sS]|[yY])
      sudo reboot
      ;;
    *)
      echo -e "${YELLOW}Run 'sudo reboot' before building the project.${RESET}"
      exit 1
      ;;
  esac
}

uninstall_dependencies() {
  # Uninstall Docker and its components
  sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo rm -rf /var/lib/docker
  sudo rm -rf /var/lib/containerd

  # Remove Docker's GPG key and repository
  sudo rm /etc/apt/keyrings/docker.asc
  sudo rm /etc/apt/sources.list.d/docker.list

  # Uninstall SONiC-vpp platform prerequisites
  sudo apt-get purge -y make automake autoconf python3-pip
  sudo pip3 uninstall -y j2cli

  # Clean up
  sudo apt-get autoremove -y
  sudo apt-get clean
}

confirm_installation() {
  echo -e "${YELLOW}This will install the following dependencies:${RESET}"
  echo -e "${YELLOW}- make${RESET}"
  echo -e "${YELLOW}- automake${RESET}"
  echo -e "${YELLOW}- autoconf${RESET}"
  echo -e "${YELLOW}- python3-pip${RESET}"
  echo -e "${YELLOW}- j2cli (via pip3)${RESET}"
  echo -e "${YELLOW}- Docker and its components${RESET}"
  echo -e "${YELLOW}Do you want to proceed? (yes/no)${RESET}"
  read -r response
  case "$response" in
    [yY][eE][sS]|[yY])
      install_dependencies
      ;;
    *)
      echo -e "${RED}Installation aborted.${RESET}"
      exit 1
      ;;
  esac
}

confirm_uninstallation() {
  echo -e "${YELLOW}This will uninstall the following dependencies:${RESET}"
  echo -e "${YELLOW}- make${RESET}"
  echo -e "${YELLOW}- automake${RESET}"
  echo -e "${YELLOW}- autoconf${RESET}"
  echo -e "${YELLOW}- python3-pip${RESET}"
  echo -e "${YELLOW}- j2cli (via pip3)${RESET}"
  echo -e "${YELLOW}- Docker and its components${RESET}"
  echo -e "${YELLOW}Do you want to proceed? (yes/no)${RESET}"
  read -r response
  case "$response" in
    [yY][eE][sS]|[yY])
      uninstall_dependencies
      ;;
    *)
      echo -e "${RED}Uninstallation aborted.${RESET}"
      exit 1
      ;;
  esac
}

case "$1" in
  --help)
    usage
    ;;
  --install)
    confirm_installation
    ;;
  --uninstall)
    confirm_uninstallation
    ;;
  *)
    error_message "Invalid argument"
    ;;
esac