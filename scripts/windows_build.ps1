$PROJECT_DIRECTORY = (Get-Item -Path (Join-Path (Get-Item -Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)) '..')).FullName
$IMAGE_NAME = 'zephyr-docker-image:local'

docker build --file "${PROJECT_DIRECTORY}\Dockerfile" --tag $IMAGE_NAME $PROJECT_DIRECTORY
