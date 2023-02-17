#!/usr/bin/env bash

# We are importing all environment variables from a file.
set -o allexport
source .env
set +o allexport

# We incrementing the application version to simulate a deployment.
APPLICATION_VERSION=$(($APPLICATION_VERSION+1))

# We are persisting the version to deploy in the .env file.
sed --in-place "/^APPLICATION_VERSION=/s/=.*/=$APPLICATION_VERSION/" .env

CONTAINER_ID=$([ "$ACTIVE_CONTAINER_ID" == "blue" ] && echo "green" || echo "blue")

echo "Deploying v$APPLICATION_VERSION.0.0 to machine '$CONTAINER_ID'..."

docker build . --tag "application:v$APPLICATION_VERSION.0.0"

docker run \
    --detach \
    --name $CONTAINER_ID \
    --hostname $CONTAINER_ID \
    --env VERSION=$APPLICATION_VERSION.0.0 \
    --env HOST=0.0.0.0 \
    --env PORT=$CONTAINER_PORT \
    application:v$APPLICATION_VERSION.0.0

# We are dynamically resolving the container IPs from the Docker daemon.
PREVIOUS_IP=$(docker inspect --format '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $ACTIVE_CONTAINER_ID)
NEXT_IP=$(docker inspect --format '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID)

# We are handling all external TCP packages.
iptables -C FORWARD -p tcp -j ACCEPT || \
iptables -I FORWARD -p tcp -j ACCEPT

# We are removing the DNAT routing rule to the previous container.
iptables -t nat -C PREROUTING -p tcp --dport $PUBLIC_PORT -j DNAT --to-destination $PREVIOUS_IP:$CONTAINER_PORT && \
iptables -t nat -D PREROUTING -p tcp --dport $PUBLIC_PORT -j DNAT --to-destination $PREVIOUS_IP:$CONTAINER_PORT

# We are adding the DNAT routing rule to the next container.
iptables -t nat -C PREROUTING -p tcp --dport $PUBLIC_PORT -j DNAT --to-destination $NEXT_IP:$CONTAINER_PORT || \
iptables -t nat -I PREROUTING -p tcp --dport $PUBLIC_PORT -j DNAT --to-destination $NEXT_IP:$CONTAINER_PORT

# We are removing the previous container.
docker rm --force $ACTIVE_CONTAINER_ID

# We are persisting the version to deploy in the .env file.
sed --in-place "/^ACTIVE_CONTAINER_ID=/s/=.*/=$CONTAINER_ID/" .env
