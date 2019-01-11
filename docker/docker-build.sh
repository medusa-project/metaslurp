#!/bin/sh

source docker/env.sh

docker build -f docker/Dockerfile \
    --build-arg secret_key_base=$SECRET_KEY_BASE \
    -t $APP_NAME \
    .
