#!/bin/bash -e

# Set login use rname
echo "USER: $USER"
export USER=${USER}

# Set login password
echo "PASSWD: $PASSWD"
mkdir ${HOME}/.vnc \
    && echo ${PASSWD} | vncpasswd -f > ${HOME}/.vnc/passwd \
    && chmod 600 ${HOME}/.vnc/passwd
touch ${HOME}/.Xresources

echo "#############################"

# Run VNC server with tail in the foreground
vncserver :1 -geometry 1280x800 -depth 24 && tail -F ${HOME}/.vnc/*.log