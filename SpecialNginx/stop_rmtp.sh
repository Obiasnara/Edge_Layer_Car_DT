# Find the docker pid and kill it (container labelled rtmp)
docker kill $(docker ps -q --filter name=rtmp)
