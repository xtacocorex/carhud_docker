FROM debian:jessie

RUN apt-get update && \
	apt-get install -yq sudo build-essential git \
	  python python3 man bash diffstat gawk chrpath wget cpio \
	  texinfo lzop apt-utils bc screen libncurses5-dev locales dosfstools \
          libc6-dev-i386 nano curl vim && \
	rm -rf /var/lib/apt-lists/*

RUN useradd -ms /bin/bash -p build build && \
    echo "build:build" | chpasswd && \
	usermod -aG sudo build

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

ENV LANG en_US.utf8

USER build

RUN mkdir -p /home/build
RUN mkdir -p /home/build/shared

# GIT PULLS
RUN cd /home/build && git clone --single-branch --branch jethro git://git.yoctoproject.org/poky.git jethro
RUN cd /home/build/jethro && \
    git clone --single-branch --branch jethro git://git.openembedded.org/meta-openembedded meta-openembedded && \
    git clone --single-branch --branch jethro git://git.yoctoproject.org/meta-raspberrypi meta-raspberrypi && \
    git clone --single-branch --branch jethro https://github.com/meta-qt5/meta-qt5.git

RUN cd /home/build && \
    mkdir -p /home/build/carhud && \
    cd /home/build/carhud && \
    git clone --single-branch --branch jethro https://github.com/xtacocorex/meta-rpi.git meta-rpi-carhud

RUN mkdir -p /home/build/carhud/build/conf
ADD bblayers.conf /home/build/carhud/build/conf
ADD local.conf /home/build/carhud/build/conf

# MAKE TEMPORARY MOUNT POINT
RUN mkdir -p /media/card

# OVERWRITE meta-raspberrypi/recipes-bsp/common/firmware.inc
ADD firmware.inc /home/build/jethro/meta-raspberrypi/recipes-bsp/common

# ADD FUN SCRIPTS TO HELP WITH BUILD
ADD do-source /home/build
ADD get-rpi-bootfiles /home/build/carhud/build
ADD get-rpi-kernel /home/build/carhud/build
ADD build-carhud-full /home/build/carhud/build
ADD build-carhud-debug /home/build/carhud/build
ADD create-debug-image home/build/carhud/build
ADD create-full-image home/build/carhud/build

# SET ENVIRONMENT VARIABLES
ENV WORKSPACE /home/build
WORKDIR /home/build

ENTRYPOINT /bin/bash
