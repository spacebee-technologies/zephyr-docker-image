#!/bin/bash

readonly IMAGE_NAME='zephyr-environment'

docker run \
  --privileged \
  --rm \
  -t \
  -i \
  -v /dev:/dev \
  "${IMAGE_NAME}"
