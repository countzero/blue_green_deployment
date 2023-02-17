#!/usr/bin/env bash

# We are using a .env file to persist state across deployments.
set -o allexport
source .env
set +o allexport

APPLICATION_VERSION=$(($APPLICATION_VERSION+1))
CONTAINER_ID=$([ "$ACTIVE_CONTAINER_ID" == "blue" ] && echo "green" || echo "blue")

echo "Deploying v$APPLICATION_VERSION.0.0 to machine '$CONTAINER_ID'..."

docker build . --tag "application:v$APPLICATION_VERSION.0.0"

# We are removing the previous container to free up its slot for this deployment.
docker rm --force $CONTAINER_ID

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

# We are waiting for the application within the machine to become available.
while (! (: </dev/tcp/$NEXT_IP/$CONTAINER_PORT) &> /dev/null); do
    echo "Waiting for the service to become available at $NEXT_IP:$CONTAINER_PORT..."
    sleep 1
done

# We are handling all external TCP packages.
iptables -C FORWARD -p tcp -j ACCEPT || iptables -I FORWARD -p tcp -j ACCEPT

# We are removing the DNAT routing rule to the previous container.
iptables -t nat -C PREROUTING -p tcp --dport $PUBLIC_PORT -j DNAT --to-destination $PREVIOUS_IP:$CONTAINER_PORT && \
iptables -t nat -D PREROUTING -p tcp --dport $PUBLIC_PORT -j DNAT --to-destination $PREVIOUS_IP:$CONTAINER_PORT

# We are adding the DNAT routing rule to the next container.
iptables -t nat -C PREROUTING -p tcp --dport $PUBLIC_PORT -j DNAT --to-destination $NEXT_IP:$CONTAINER_PORT || \
iptables -t nat -I PREROUTING -p tcp --dport $PUBLIC_PORT -j DNAT --to-destination $NEXT_IP:$CONTAINER_PORT

# We are persisting the new state in the .env file for the next deployment.
sed --in-place "/^ACTIVE_CONTAINER_ID=/s/=.*/=$CONTAINER_ID/" .env
sed --in-place "/^APPLICATION_VERSION=/s/=.*/=$APPLICATION_VERSION/" .env
