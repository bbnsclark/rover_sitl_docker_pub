xhost +local:root

docker run -it \
    --gpus all \
    --hostname="rover" \
    --env="DISPLAY" \
    --privileged \
    --device /dev/dri \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    -p 9090:9090 \
    -p 11311:11311 \
    rover_sitl

xhost -local:root
