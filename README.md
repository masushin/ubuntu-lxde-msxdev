# ubuntu-lxde-msxdev

MSX development (Japanese) environment based on ubuntu20.04 using docker on Mac.
The following are included.

* lxde + fcitx (Japanese Input Method)
* Visual Source Code
* z88dk (Development tools for Z80)
* openMSX / openMSX debugger
* MAME + c-bios driver
* nMSXtiles (pattern editor for MSX)
* multipaint (Draw tool supported for Retro PC format)

## lxde + fcitx

GUI Environment.

## Visual Source Code

Currently, the following steps are required to run as root.

* Preparation
```
$ sudo su
$ cp /home/msx/.Xauthority /root
$ exit
```

* Start VSCode as root 
```
$ sudo code --user-data-dir="/root" --no-sandbox
```

## z88dk
## openMSX / openMSX debugger
## MAME + c-bios driver
## nMSXtiles

These have been implemented with reference to the following.

https://maple4estry.netlify.app/z88dk-msx/

https://maple4estry.netlify.app/mame-msx-cbios/


## multipaint

http://multipaint.kameli.net/


# Preparing steps to boot MSXDEV docker environment on Mac

## Install and run pulseaudio

### Install pulseaudio
```
$ brew install pulseaudio
```

### Start pulseaudio
```
$ pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon
```
This step is required every time you reboot your Mac.

Refer：https://qiita.com/Mco7777/items/18e29b98ddbc2614169b



## Install VNC client

https://www.realvnc.com/en/connect/download/viewer/

Other VNC clients may be used.


## Edit docker-compose.yml

Change the following parts according to your environment.
This is for mounting the working directory, so remove it if you don't need it.

```
      - type: bind
        source: ~/work/msx
        target: /home/msx/devmsx
```

## docker build

```
$ docker-compose build
```

# docker run

1. start docker
```
$ docker-compose up
```

2. Connect to ```127.0.0.1:5901``` by VNC client

VNC password is ```password```.

