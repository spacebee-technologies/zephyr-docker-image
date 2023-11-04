$IMAGE_NAME = 'zephyr-docker-image:local'

docker run --privileged --rm -t -i -v /dev:/dev "${IMAGE_NAME}"
