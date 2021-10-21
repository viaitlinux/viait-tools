#!/bin/bash

setupReq () {
    pacman -Syuu --noconfirm
    pacman -S --noconfirm archlinux-keyring
    pacman -S --needed --noconfirm archiso mkinitcpio-archiso
}