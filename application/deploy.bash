#!/usr/bin/env bash

docker build . --tag application:v1.0.0

docker run -p 80:80 --name blue -d application:v1.0.0

# TODO: Implement...
