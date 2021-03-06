#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

update_system() {
    if [[ -n "$(command -v apt-get)" ]]; then
        info "Removing old vagrant packages."
        apt-get -y remove vagrant > /dev/null 2>&1 || true
        info "Updating repositories."
        apt-get -y update > /dev/null 2>&1 || fatal "Failed to get updates from apt."
        if [[ ${CI:-} != true ]] && [[ ${TRAVIS:-} != true ]]; then
            info "Upgrading packages. Please be patient, this can take a while."
            apt-get -y dist-upgrade > /dev/null 2>&1 || fatal "Failed to upgrade packages from apt."
        fi
        info "Installing dependencies."
        apt-get -y install apt-transport-https curl git grep python python-pip rsync sed whiptail > /dev/null 2>&1 || fatal "Failed to install dependencies from apt."
        # https://cryptography.io/en/latest/installation/#building-cryptography-on-linux
        apt-get -y install build-essential libssl-dev libffi-dev python3-dev > /dev/null 2>&1 || fatal "Failed to install python cryptography dependencies from apt."
        info "Removing unused packages."
        apt-get -y autoremove > /dev/null 2>&1 || fatal "Failed to remove unused packages from apt."
        info "Cleaning up package cache."
        apt-get -y autoclean > /dev/null 2>&1 || fatal "Failed to cleanup cache from apt."
    else
        fatal "Package manager not detected!"
    fi
}
