FROM ubuntu:20.04

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    lxde \
    fcitx-mozc \
    language-pack-ja-base \
    language-pack-ja \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho \
    tigervnc-standalone-server \
    tigervnc-xorg-extension \
    sudo \
    pulseaudio \
    alsa-utils \
    curl \
    wget \
    git \
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
    cmake \
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
    tcl-dev \
    qtbase5-dev \
    qtbase5-dev-tools \
    qtchooser \
    qt5-qmake \
    python \
    libfontconfig-dev \
    default-jre \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*    

# VSCode
WORKDIR /opt
RUN curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o vscode.deb && \
    apt install ./vscode.deb

# z88dk
RUN git clone --recursive https://github.com/z88dk/z88dk.git && \
    cd z88dk && \
    export BUILD_SDCC=1 && \
    export BUILD_SDCC_HTTP=1 && \
    ./build.sh

# openMSX
RUN git clone https://github.com/openMSX/openMSX.git && \
    cd openMSX && \
    ./configure && \
    make -j"$(nproc)" OPENMSX_TARGET_CPU=x86_64 OPENMSX_TARGET_OS=linux OPENMSX_FLAVOUR=opt staticbindist

# openMSX debugger
RUN git clone https://github.com/openMSX/debugger
COPY etc/0001-add-z88dk-symbol-read-hack.patch /opt/debugger
RUN cd debugger && \
    patch -p1 < 0001-add-z88dk-symbol-read-hack.patch && \
    make -j"$(nproc)"

# MAME
RUN git clone https://github.com/mamedev/mame.git
COPY etc/cbios.patch /opt/mame
RUN cd mame && \
    git checkout ec9ba6f && \
    patch -p1 < ./cbios.patch && \
    make -j"$(nproc)" SUBTARGET=cbios SOURCES=src/mame/drivers/msx.cpp && \
    mkdir roms/cbios && cp /opt/openMSX/derived/x86_64-linux-opt-3rd/bindist/install/share/machines/*.rom /opt/mame/roms/cbios

# nMSXtiles
RUN git clone https://github.com/pipagerardo/nMSXtiles.git && \
    cd nMSXtiles/src && \
    qmake && \
    make -j"$(nproc)"

# multipaint
RUN wget http://multipaint.kameli.net/multipaint.zip && \
    unzip multipaint.zip

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
COPY start.sh /tmp/
RUN chmod +x /tmp/start.sh

COPY etc/multipaint.desktop /usr/share/applications
COPY etc/openmsx.desktop /usr/share/applications
COPY etc/openmsx-debugger.desktop /usr/share/applications
COPY etc/code.desktop /usr/share/applications
COPY etc/nMSXtiles.desktop /usr/share/applications

USER ${USER}
WORKDIR /home/${USER}
ADD --chown=${USER}:developer config/ /home/${USER}/
RUN cp -Rfp /opt/openMSX/derived/x86_64-linux-opt-3rd/bindist/install/share/ ~/.openMSX && \
    cd ~/.openMSX && patch -p1 < ./openmsx-defaultmachine-setting.patch

RUN echo 'alias code="code --no-sandbox"' >> ~/.bash_aliases && \
    echo 'export Z88DK_HOME=/opt/z88dk' >> ~/.bashrc && \
    echo 'export ZCCCFG=${Z88DK_HOME}/lib/config' >> ~/.bashrc && \
    echo 'export PATH=${Z88DK_HOME}/bin:${PATH}' >> ~/.bashrc && \
    echo 'export PATH=/opt/openMSX/derived/x86_64-linux-opt-3rd/bindist/install/bin:${PATH}' >> ~/.bashrc && \
    echo 'export PATH=/opt/debugger/derived/bin:${PATH}' >> ~/.bashrc && \
    echo 'export PATH=/opt/mame:${PATH}' >> ~/.bashrc && \
    echo 'export PATH=/opt/nMSXtiles/build:${PATH}' >> ~/.bashrc && \
    echo 'export PATH=/opt/multipaint/application.linux64:${PATH}' >> ~/.bashrc

# Command
CMD ["/tmp/start.sh"]