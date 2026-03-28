FROM ubuntu:22.04

# Configuration
ARG ZEPHYR_VERSION=v3.7.1
ARG ZEPHYR_SDK_VERSION=0.16.9
ARG USERNAME=builder
ARG USER_UID=1000
ARG USER_GID=1000
ARG USER_HOME=/home/${USERNAME}
ARG VENV_PATH=/opt/venv
ARG ZEPHYR_ROOT=/opt/zephyrproject

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="${VENV_PATH}/bin:${PATH}"
ENV ZEPHYR_BASE="${ZEPHYR_ROOT}/zephyr"

# Install dependencies
WORKDIR /tmp
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget apt-transport-https gpg udev && \
    wget https://apt.kitware.com/kitware-archive.sh && \
    bash kitware-archive.sh && \
    apt-get install -y --no-install-recommends \
        openocd \
        git cmake ninja-build gperf ccache dfu-util device-tree-compiler \
        python3-dev python3-pip python3-setuptools python3-tk python3-wheel python3-venv \
        xz-utils file make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1 \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# Create non-root user
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd -m --uid ${USER_UID} --gid ${USER_GID} -s /bin/bash ${USERNAME} && \
    usermod -aG dialout ${USERNAME}

# Create shared virtual environment and install west
RUN python3 -m venv "${VENV_PATH}" && \
    "${VENV_PATH}/bin/pip" install --upgrade pip && \
    "${VENV_PATH}/bin/pip" install west

# Install Zephyr
WORKDIR /opt
RUN west init --mr "${ZEPHYR_VERSION}" "${ZEPHYR_ROOT}"
WORKDIR "${ZEPHYR_ROOT}"
RUN west update
RUN west zephyr-export
RUN "${VENV_PATH}/bin/pip" install -r "${ZEPHYR_ROOT}/zephyr/scripts/requirements.txt"

# Install Zephyr SDK
WORKDIR /tmp
ARG ZEPHYR_SDK_DOWNLOAD_URL=https://github.com/zephyrproject-rtos/sdk-ng/releases/download
RUN wget "${ZEPHYR_SDK_DOWNLOAD_URL}/v${ZEPHYR_SDK_VERSION}/zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz" && \
    wget -O - "${ZEPHYR_SDK_DOWNLOAD_URL}/v${ZEPHYR_SDK_VERSION}/sha256.sum" | shasum --check --ignore-missing && \
    tar xvf "zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz" -C /opt && \
    rm "zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz"
WORKDIR "/opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}"
RUN ./setup.sh -t all -h -c

# Make shared tools readable by any runtime user
RUN chmod -R a+rX "${VENV_PATH}" "${ZEPHYR_ROOT}" "/opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}"

# Add workspace as safe git directory
RUN git config --system --add safe.directory /workspace

WORKDIR /workspace

USER ${USERNAME}
