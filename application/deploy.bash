#!/usr/bin/env bash

docker build . --tag application:v1.0.0

docker run --publish 80:80 --name blue --env VERSION=blue --detach application:v1.0.0


# TODO: Implement...
