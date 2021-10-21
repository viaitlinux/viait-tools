#!/bin/bash

##----------------------------##
#viait-tools build script
#
#-----------------------------##



isSudo () {
    if [[ "$EUID" = 0 ]]; then
        continue
    else
        echo "root access is not detected"
        exit
    fi
}

handleError () {
    clear
    set -uo pipefall
    trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
}

cleanFiles () {
    [[ -d ./viaitrel ]] && rm -r ./viaitrel
    [[ -d ./viait-work ]] && rm -r ./viait-work
    [[ -d ./viait-output ]] && rm -r ./viait-output
    sleep 2
}

setupReq () {
    pacman -Syuu --noconfirm
    pacman -S --noconfirm archlinux-keyring
    pacman -S --needed --noconfirm archiso mkinitcpio-archiso
}

isSudo
handleError
setupReq
cleanFiles
sh ./scripts/viaitstrap.sh