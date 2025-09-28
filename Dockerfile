FROM ubuntu:22.04

# Configuration
ARG ZEPHYR_VERSION=v3.7.1
ARG ZEPHYR_SDK_VERSION=0.16.9
ARG USER_HOME="/root"
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="${PATH}:${USER_HOME}/.local/bin"
ENV ZEPHYR_BASE="${USER_HOME}/zephyrproject/zephyr"

# Install dependencies
WORKDIR /tmp
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget apt-transport-https gpg udev && \
    wget https://apt.kitware.com/kitware-archive.sh && \
    bash kitware-archive.sh && \
    apt-get install -y --no-install-recommends \
        git cmake ninja-build gperf ccache dfu-util device-tree-compiler \
        python3-dev python3-pip python3-setuptools python3-tk python3-wheel \
        xz-utils file make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1 \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# Install Zephyr
WORKDIR "${USER_HOME}/zephyrproject"
RUN pip3 install -U west
RUN west init --mr "${ZEPHYR_VERSION}" "${USER_HOME}/zephyrproject"
RUN west update
RUN west zephyr-export
RUN pip3 install -r "${USER_HOME}/zephyrproject/zephyr/scripts/requirements.txt"

# Install Zephyr SDK
WORKDIR /tmp
ARG ZEPHYR_SDK_DOWNLOAD_URL=https://github.com/zephyrproject-rtos/sdk-ng/releases/download
RUN wget "${ZEPHYR_SDK_DOWNLOAD_URL}/v${ZEPHYR_SDK_VERSION}/zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz" && \
    wget -O - "${ZEPHYR_SDK_DOWNLOAD_URL}/v${ZEPHYR_SDK_VERSION}/sha256.sum" | shasum --check --ignore-missing && \
    tar xvf "zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz" -C "${USER_HOME}" && \
    rm "zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz"
WORKDIR "${USER_HOME}/zephyr-sdk-${ZEPHYR_SDK_VERSION}"
RUN ./setup.sh -t all -h -c

# Add workspace as safe git directory
RUN git config --global --add safe.directory /workspace

# Install OpenOCD
RUN apt install openocd -y

WORKDIR /workspace
