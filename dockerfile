FROM ubuntu:20.04

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y lxde

RUN apt install -y fcitx-mozc \
    language-pack-ja-base \
    language-pack-ja \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho

RUN apt install -y \
    sudo \
    tightvncserver \
    pulseaudio \
    alsa-utils \
    curl \
    wget \
    git \
    autocutsel

RUN apt install -y \
    build-essential \
    dos2unix \
    libboost-all-dev \
    texinfo \
    texi2html \
    libxml2-dev \
    subversion \
    bison \
    flex \
    zlib1g-dev \
    m4 \
    cmake

# VSCode
WORKDIR /opt
RUN curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o vscode.deb && apt install ./vscode.deb

# z88dk
RUN git clone --recursive https://github.com/z88dk/z88dk.git 
WORKDIR z88dk
RUN ./build.sh

# openMSX dependecies
RUN sudo apt install -y \ 
    libgl1-mesa-dev \
    libxext-dev \
    libasound2-dev \
    libglew-dev \
    libogg-dev \
    libpng-dev \
    libtheora-dev \
    libvorbis-dev \
    libsdl2-dev \
    libsdl2-ttf-dev \
    tcl-dev

WORKDIR /opt
RUN git clone https://github.com/openMSX/openMSX.git
WORKDIR openMSX
RUN ./configure && make OPENMSX_TARGET_CPU=x86_64 OPENMSX_TARGET_OS=linux OPENMSX_FLAVOUR=opt staticbindist

# openMSX debugger
WORKDIR /opt
RUN apt install -y qtbase5-dev qtbase5-dev-tools qtchooser qt5-qmake
RUN git clone https://github.com/openMSX/debugger
WORKDIR debugger
RUN wget https://gist.githubusercontent.com/h1romas4/5f6579fcaad77cab3413ff437188a2f2/raw/684e09c78d6f16a08c03f2f5353b70ffc24e909a/0001-add-z88dk-symbol-read-hack.patch && \
    patch -p1 < 0001-add-z88dk-symbol-read-hack.patch
RUN make

# MAME
WORKDIR /opt
RUN apt install -y \
    python \
    libfontconfig-dev
RUN git clone https://github.com/mamedev/mame.git
WORKDIR mame
RUN git checkout ec9ba6f
RUN make -j 2 SUBTARGET=hbf1 SOURCES=src/mame/drivers/msx.cpp

# Locale
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && echo 'Asia/Tokyo' > /etc/timezone
RUN locale-gen ja_JP.UTF-8 \
    && echo 'LC_ALL=ja_JP.UTF-8' > /etc/default/locale \
    && echo 'LANG=ja_JP.UTF-8' >> /etc/default/locale
ENV LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP:ja \
    LC_ALL=ja_JP.UTF-8

# User
ENV USER=msx \
    PASSWD=password

RUN groupadd -g 1000 developer && \
    useradd  -g      developer -G sudo -m -s /bin/bash msx && \
    echo $USER:$PASSWD | chpasswd
    
RUN echo 'Defaults visiblepw'             >> /etc/sudoers
RUN echo $USER 'ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Start script
COPY start.sh /opt/
RUN chmod +x /opt/start.sh

USER ${USER}
WORKDIR /home/${USER}
RUN mkdir ~/.config && sudo chown ${USER}:developer ~/.config
RUN mkdir ~/.openMSX && \
     cp -Rfp /opt/openMSX/derived/x86_64-linux-opt-3rd/bindist/install/share/ ~/.openMSX && \
     sudo chown -R ${USER}:developer ~/.openMSX

RUN echo 'alias code="code --no-sandbox"' >> ~/.bash_aliases
RUN echo 'export Z88DK_HOME=/opt/z88dk' >> ~/.bashrc
RUN echo 'export ZCCCFG=${Z88DK_HOME}/lib/config' >> ~/.bashrc
RUN echo 'export PATH=${Z88DK_HOME}/bin:${PATH}' >> ~/.bashrc
RUN echo 'export PATH=/opt/openMSX/derived/x86_64-linux-opt-3rd/bindist/install/bin:${PATH}' >> ~/.bashrc
RUN echo 'export PATH=/opt/debugger/derived/bin:${PATH}' >> ~/.bashrc

# Command
CMD ["/opt/start.sh"]