#!/bin/bash

# Color constants
YELLOW="\e[33m"
RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

usage() {
  echo -e "${YELLOW}Usage: $0 [OPTIONS]${RESET}"
  echo -e "${YELLOW}Options:${RESET}"
  echo -e "${YELLOW}  --make-jobs <number_of_cpu_cores>  Specify the number of CPU cores to use for SONIC_CONFIG_MAKE_JOBS.${RESET}"
  echo -e "${YELLOW}  --protobuf <number_of_cpu_cores>   Specify the number of CPU cores for protobuf tests.${RESET}"
  echo -e "${YELLOW}  --make-jobs-revert                 Revert the SONIC_CONFIG_MAKE_JOBS setting to the default.${RESET}"
  echo -e "${YELLOW}  --protobuf-revert                  Revert the protobuf tests setting to default.${RESET}"
  echo -e "${YELLOW}  --help                             Display this help message.${RESET}"
  exit 1
}

error_message() {
  echo -e "${RED}Error: $1. Use --help for more information.${RESET}"
  exit 1
}

check_command() {
  command -v "$1" >/dev/null 2>&1 || error_message "$1 command not found"
}

check_file() {
  [ ! -f "$1" ] && error_message "File $1 not found!"
}

# Check required commands
check_command "sed"
check_command "nproc"

# File paths (rename for the correct path)
ROOT=$(git rev-parse --show-toplevel)
FILE_PATH="$ROOT/build/sonic-buildimage/rules/config"
PROTOBUF_TESTS_PATH="$ROOT/build/sonic-buildimage/src/protobuf/protobuf-3.21.12/tests.sh"

MAX_CORES=$(nproc)

update_make_jobs() {
  check_file "$FILE_PATH"
  local cpu_cores=$1
  if [ "$cpu_cores" -lt 1 ] || [ "$cpu_cores" -gt "$MAX_CORES" ]; then
    error_message "Number of CPU cores must be between 1 and $MAX_CORES"
  fi
  sed -i "s/SONIC_CONFIG_MAKE_JOBS = .*/SONIC_CONFIG_MAKE_JOBS = $cpu_cores/" "$FILE_PATH"
  echo -e "Updated ${GREEN}SONIC_CONFIG_MAKE_JOBS${RESET} to ${GREEN}$cpu_cores${RESET} in $FILE_PATH"
}

revert_make_jobs() {
  check_file "$FILE_PATH"
  sed -i "s/SONIC_CONFIG_MAKE_JOBS = .*/SONIC_CONFIG_MAKE_JOBS = \$(shell nproc)/" "$FILE_PATH"
  echo -e "Reverted ${GREEN}SONIC_CONFIG_MAKE_JOBS${RESET} to ${GREEN}\$(shell nproc)${RESET} in $FILE_PATH"
}

update_protobuf() {
  check_file "$PROTOBUF_TESTS_PATH"
  local cpu_cores=$1
  if [ "$cpu_cores" -lt 1 ] || [ "$cpu_cores" -gt "$MAX_CORES" ]; then
    error_message "Number of CPU cores must be between 1 and $MAX_CORES"
  fi
  sed -i "s/-j\$(nproc)/-j$cpu_cores/g" "$PROTOBUF_TESTS_PATH"
  sed -i "s/-j[0-9]\+/-j$cpu_cores/g" "$PROTOBUF_TESTS_PATH"
  echo -e "Updated ${GREEN}protobuf tests${RESET} to use ${GREEN}$cpu_cores${RESET} cores in $PROTOBUF_TESTS_PATH"
}

revert_protobuf() {
  check_file "$PROTOBUF_TESTS_PATH"
  sed -i "s/-j[0-9]\+/-j\$(nproc)/g" "$PROTOBUF_TESTS_PATH"
  echo -e "Reverted ${GREEN}protobuf tests${RESET} to use ${GREEN}\$(nproc)${RESET} cores in $PROTOBUF_TESTS_PATH"
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  error_message "Invalid number of arguments"
fi

case "$1" in
  --help)
    usage
    ;;
  --make-jobs)
    if [ "$#" -ne 2 ] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
      error_message "Invalid argument for --make-jobs"
    fi
    update_make_jobs "$2"
    ;;
  --protobuf)
    if [ "$#" -ne 2 ] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
      error_message "Invalid argument for --protobuf"
    fi
    update_protobuf "$2"
    ;;
  --make-jobs-revert)
    if [ "$#" -ne 1 ]; then
      error_message "Invalid argument for --make-jobs-revert"
    fi
    revert_make_jobs
    ;;
  --protobuf-revert)
    if [ "$#" -ne 1 ]; then
      error_message "Invalid argument for --protobuf-revert"
    fi
    revert_protobuf
    ;;
  *)
    error_message "Invalid argument"
    ;;
esac