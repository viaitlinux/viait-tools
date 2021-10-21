#!/bin/bash

USERNAME="viaitlive"
PASS="viaitlive"
PASSROOT="viaitroot"
HOSTNAME="viaitlinux"
LOC="en_US"
KBDMAP="us"
KBDMOD="pc105"

copyBaseProfile () {
    cp -r /usr/share/archiso/configs/releng ./viaitrel
    rm -rf ./viaitrel/efiboot
    rm -rf ./viaitrel/syslinux
}

cleanLocalRepo () {
    rm -rf ./custom/opt/viait-local/*.db
    rm -rf ./custom/opt/viait-local/*.gz
}

removeCloudInit () {
    [[ -d ./viaitrel/airootfs/etc/systemd/system/cloud-init.target.wants ]] && rm -r ./viaitrel/airootfs/etc/systemd/system/cloud-init.target.wants
    [[ -f ./viaitrel/airootfs/etc/systemd/system/multi-user.target.wants/iwd.service ]] && rm ./viaitrel/airootfs/etc/systemd/system/multi-user.target.wants/iwd.service
    [[ -f ./viaitrel/airootfs/etc/xdg/reflector/reflector.conf ]] && rm ./viaitrel/airootfs/etc/xdg/reflector/reflector.conf
}

createSymLinks () {
    [[ ! -d ./viaitrel/airootfs/etc/systemd/system/sysinit.target.wants ]] && mkdir -p ./viaitrel/airootfs/etc/systemd/system/sysinit.target.wants
    [[ ! -d ./viaitrel/airootfs/etc/systemd/system/network-online.target.wants ]] && mkdir -p ./viaitrel/airootfs/etc/systemd/system/network-online.target.wants
    [[ ! -d ./viaitrel/airootfs/etc/systemd/system/multi-user.target.wants ]] && mkdir -p ./viaitrel/airootfs/etc/systemd/system/multi-user.target.wants
    [[ ! -d ./viaitrel/airootfs/etc/systemd/system/printer.target.wants ]] && mkdir -p ./viaitrel/airootfs/etc/systemd/system/printer.target.wants
    [[ ! -d ./viaitrel/airootfs/etc/systemd/system/sockets.target.wants ]] && mkdir -p ./viaitrel/airootfs/etc/systemd/system/sockets.target.wants
    ln -sf /usr/lib/systemd/system/NetworkManager-wait-online.service ./viaitrel/airootfs/etc/systemd/system/network-online.target.wants/NetworkManager-wait-online.service
    ln -sf /usr/lib/systemd/system/NetworkManager.service ./viaitrel/airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service
    ln -sf /usr/lib/systemd/system/NetworkManager-dispatcher.service ./viaitrel/airootfs/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
    ln -sf /usr/lib/systemd/system/sddm.service ./viaitrel/airootfs/etc/systemd/system/display-manager.service
    ln -sf /usr/lib/systemd/system/haveged.service ./viaitrel/airootfs/etc/systemd/system/sysinit.target.wants/haveged.service
    ln -sf /usr/lib/systemd/system/cups.service ./viaitrel/airootfs/etc/systemd/system/printer.target.wants/cups.service
    ln -sf /usr/lib/systemd/system/cups.socket ./viaitrel/airootfs/etc/systemd/system/sockets.target.wants/cups.socket
    ln -sf /usr/lib/systemd/system/cups.path ./viaitrel/airootfs/etc/systemd/system/multi-user.target.wants/cups.path
}

copyViaitFiles () {
    cp ./custom/packages.x86_64 ./viaitrel/
    cp ./custom/pacman.conf ./viaitrel/
    cp ./custom/profiledef.sh ./viaitrel/
    cp -rf ./custom/efiboot ./viaitrel/
    cp -rf ./custom/syslinux ./viaitrel/
    cp -rf ./custom/usr ./viaitrel/airootfs
    cp -rf ./custom/etc ./viaitrel/airootfs
    cp -rf ./custom/opt ./viaitrel/airootfs
}

setHostname () {
    echo "$HOSTNAME" > ./viaitrel/airootfs/etc/hostname
}

createPasswdFile () {
    echo "root:x:0:0:root:/root:/usr/bin/bash 
    "${USERNAME}":x:1010:1010::/home/"${USERNAME}":/bin/zsh" > ./viaitrel/airootfs/etc/passwd
}

# Create group file
createGroups () {
    echo "root:x:0:root
    sys:x:3:"${USERNAME}"
    adm:x:4:"${USERNAME}"
    wheel:x:10:"${USERNAME}"
    log:x:19:"${USERNAME}"
    network:x:90:"${USERNAME}"
    floppy:x:94:"${USERNAME}"
    scanner:x:96:"${USERNAME}"
    power:x:98:"${USERNAME}"
    rfkill:x:850:"${USERNAME}"
    users:x:985:"${USERNAME}"
    video:x:860:"${USERNAME}"
    storage:x:870:"${USERNAME}"
    optical:x:880:"${USERNAME}"
    lp:x:840:"${USERNAME}"
    audio:x:890:"${USERNAME}"
    "${USERNAME}":x:1010:" > ./viaitrel/airootfs/etc/group
}

crtshadow () {
    usr_hash=$(openssl passwd -6 "${PASS}")
    root_hash=$(openssl passwd -6 "${PASSROOT}")
    echo "root:"${root_hash}":14871::::::
    "${USERNAME}":"${usr_hash}":14871::::::" > ./viaitrel/airootfs/etc/shadow
}

crtgshadow () {
echo "root:!*::root
"${USERNAME}":!*::" > ./viaitrel/airootfs/etc/gshadow
}

setkeylayout () {
echo "KEYMAP="${KBDMAP}"" > ./viaitrel/airootfs/etc/vconsole.conf
}

crtkeyboard () {
mkdir -p ./viaitrel/airootfs/etc/X11/xorg.conf.d
echo "Section \"InputClass\"
        Identifier \"system-keyboard\"
        MatchIsKeyboard \"on\"
        Option \"XkbLayout\" \""${KBDMAP}"\"
        Option \"XkbModel\" \""${KBDMOD}"\"
EndSection" > ./viaitrel/airootfs/etc/X11/xorg.conf.d/00-keyboard.conf
}

crtlocalec () {
sed -i "s/en_US/"${LOC}"/g" ./viaitrel/airootfs/etc/pacman.d/hooks/40-locale-gen.hook
echo "LANG="${LOC}".UTF-8" > ./viaitrel/airootfs/etc/locale.conf
}

buildisofile () {
    mkarchiso -vv -w ./viait-work -o ./viait-ouput ./viaitrel
    sudo chown -R ${USER} ./
}


copyBaseProfile
createSymLinks
cleanLocalRepo
./scripts/viaitrepo.sh
removeCloudInit
copyViaitFiles
setHostname
createPasswdFile
createGroups
crtshadow
crtgshadow
setkeylayout
crtkeyboard
crtlocalec
buildisofile
