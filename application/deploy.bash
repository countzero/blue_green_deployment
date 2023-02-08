#!/usr/bin/env bash

CONTAINER_PORT=9090
PUBLIC_PORT=80

docker build . --tag application:v1.0.0

docker run \
    --detach \
    --name green \
    --env VERSION=green \
    --env HOST=0.0.0.0 \
    --env PORT=$CONTAINER_PORT \
    application:v1.0.0

docker run \
    --detach \
    --name blue \
    --env VERSION=blue \
    --env HOST=0.0.0.0 \
    --env PORT=$CONTAINER_PORT \
    application:v1.0.0

GREEN_IP=$(docker inspect --format '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' green)
BLUE_IP=$(docker inspect --format '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' blue)

# We are handling all external TCP packages.
iptables -I FORWARD 1 -p tcp --dport $PUBLIC_PORT -j ACCEPT -m comment --comment "Accept public TCP traffic"

# DNAT - local traffic
iptables -t nat -I OUTPUT 1 -p tcp --dport $PUBLIC_PORT \
    -m statistic --mode random --probability 1.0  \
    -j DNAT --to-destination $GREEN_IP:$CONTAINER_PORT

iptables -t nat -I OUTPUT 1 -p tcp --dport $PUBLIC_PORT \
    -m statistic --mode random --probability 0.5  \
    -j DNAT --to-destination $BLUE_IP:$CONTAINER_PORT

# DNAT - external traffic
iptables -t nat -I PREROUTING 1 -p tcp --dport $PUBLIC_PORT \
    -m statistic --mode random --probability 1.0  \
    -j DNAT --to-destination $GREEN_IP:$CONTAINER_PORT

iptables -t nat -I PREROUTING 1 -p tcp --dport $PUBLIC_PORT \
    -m statistic --mode random --probability 0.5  \
    -j DNAT --to-destination $BLUE_IP:$CONTAINER_PORT
