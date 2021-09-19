FROM ubuntu

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y lxde

RUN apt install -y \
    ibus \
    ibus-mozc \
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
    openmsx \
    autocutsel

# VSCode
WORKDIR /root
RUN curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o vscode.deb && apt install ./vscode.deb

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

# Command
CMD ["/opt/start.sh"]