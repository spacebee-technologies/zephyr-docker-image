FROM ubuntu:20.04

# Configuration
ARG ZEPHYR_SDK_VERSION=0.15.1
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="${PATH}:/root/.local/bin"
ENV ZEPHYR_BASE=/root/zephyrproject/zephyr

# Basic dependencies
RUN apt-get update && apt-get install -y wget apt-transport-https gpg udev

# Install OS dependencies
WORKDIR /tmp
RUN wget https://apt.kitware.com/kitware-archive.sh
RUN bash kitware-archive.sh
RUN apt-get install -y --no-install-recommends \
        git cmake ninja-build gperf ccache dfu-util device-tree-compiler \
        python3-dev python3-pip python3-setuptools python3-tk python3-wheel \
        xz-utils file make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1

# Install Zephyr
WORKDIR /root/zephyrproject
RUN pip3 install --user -U west
RUN west init /root/zephyrproject
RUN west update
RUN west zephyr-export
RUN pip3 install --user -r /root/zephyrproject/zephyr/scripts/requirements.txt

# Install Zephyr SDK
WORKDIR /tmp
ARG ZEPHYR_SDK_DOWNLOAD_URL=https://github.com/zephyrproject-rtos/sdk-ng/releases/download
RUN wget $ZEPHYR_SDK_DOWNLOAD_URL/v$ZEPHYR_SDK_VERSION/zephyr-sdk-$ZEPHYR_SDK_VERSION_linux-x86_64.tar.gz
RUN wget -O - $ZEPHYR_SDK_DOWNLOAD_URL/v$ZEPHYR_SDK_VERSION/sha256.sum | shasum --check --ignore-missing
RUN tar xvf zephyr-sdk-$ZEPHYR_SDK_VERSION_linux-x86_64.tar.gz -C /root
WORKDIR /root/zephyr-sdk-$ZEPHYR_SDK_VERSION
RUN ./setup.sh -t all -h -c

WORKDIR /workspace
