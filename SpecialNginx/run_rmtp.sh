#!/bin/bash

# Example: ./run_rmtp.sh logs=true

# Get the argument logs=X
for i in "$@"
do
case $i in
    logs=*)
    LOGS="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

# Build the Docker image
docker buildx build -t rtmp .

# Run the Docker container
docker run -d -p 1935:1935 -p 80:80 -p 3478:3478 -p 5349:5349 --cap-add=NET_ADMIN rtmp > rtmp_container_id

# Show the logs
if [ "$LOGS" = "true" ]; then
    docker logs -f -t $(cat rtmp_container_id)
#Else attach to the container
else
    docker exec -it $(cat rtmp_container_id) /bin/bash
fi
