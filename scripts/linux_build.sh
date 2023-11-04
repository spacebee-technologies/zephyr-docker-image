#!/bin/bash

readonly PROJECT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && cd .. && pwd)"
readonly IMAGE_NAME='zephyr-docker-image:local'

docker build -f "${PROJECT_DIRECTORY}/Dockerfile" -t "${IMAGE_NAME}" "${PROJECT_DIRECTORY}"
