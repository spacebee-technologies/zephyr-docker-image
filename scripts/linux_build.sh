#!/bin/bash

readonly PROJECT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && cd .. && pwd)"
readonly IMAGE_NAME='zephyr-environment'

docker build \
  -f "${PROJECT_DIRECTORY}/Dockerfile" \
  -t "${IMAGE_NAME}" \
  "${PROJECT_DIRECTORY}"
