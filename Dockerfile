FROM ros:melodic-perception
LABEL maintainer="giovani.diniz@raytheon.com"

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get install -y \
    libglvnd0 mesa-utils apt-utils wget

# now let's install nvidia drivers on the container
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin && \
    sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
    wget http://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda-repo-ubuntu1804-10-2-local-10.2.89-440.33.01_1.0-1_amd64.deb && \
    sudo dpkg -i cuda-repo-ubuntu1804-10-2-local-10.2.89-440.33.01_1.0-1_amd64.deb && \
    sudo apt-key add /var/cuda-repo-10-2-local-10.2.89-440.33.01/7fa2af80.pub && \
    sudo apt-get update && \
    sudo apt-get install -y cuda

# installing ros-specific stuff 
RUN apt-get update && apt-get install -y ros-melodic-move-base ros-melodic-move-base-msgs ros-melodic-desktop-full \
    ros-melodic-slam-gmapping ros-melodic-map-server ssh ros-melodic-rosbridge-suite ros-melodic-apriltag-ros \
    ros-melodic-costmap-2d* ros-melodic-gpsd-client ros-melodic-gps-common ros-melodic-gps-umd \
    ros-melodic-rtabmap-ros ros-melodic-robot-localization ros-melodic-dwa-local-planner \
    ros-melodic-hector-gazebo-plugins ros-melodic-async-web-server-cpp 

# installing dependencies
RUN apt-get update && apt-get install -y python-opencv python-wxgtk3.0 python3-pip python3-matplotlib python-pygame \
    python3-lxml python3-yaml socat vim wget screen sudo lsb-release tzdata wget libgps-dev \
    python-pip

RUN sudo apt update && sudo apt upgrade -y

RUN sudo -H python -m pip install websocket-client utm

# now, we create our own overlay worskpace
RUN mkdir -p ~/rover/src

RUN eval $(ssh-agent) && \
    cd ~/rover/src && \
    git clone https://github.com/radarku/rover_gazebo.git && \
    git clone https://github.com/radarku/rover_description.git && \
    git clone https://github.com/radarku/rover_launcher.git && \
    git clone https://github.com/radarku/rover_launcher_sitl.git && \
    git clone https://github.com/radarku/global_position_controller.git && \
    git clone https://github.com/radarku/gps_driver_sitl.git && \
    git clone https://github.com/radarku/gps_converter.git && \
    git clone https://github.com/radarku/map_localization.git && \
    git clone https://github.com/radarku/explore.git && \
    git clone https://github.com/radarku/sitl_firmware.git && \
    git clone https://github.com/radarku/state_observer.git && \
    git clone https://github.com/RobotWebTools/web_video_server.git && \
    git clone https://github.com/AprilRobotics/apriltag_ros.git && \
    git clone https://github.com/AprilRobotics/apriltag.git

# finally, we build the system with catkin
RUN . /opt/ros/melodic/setup.sh && cd ~/rover/ && catkin_make_isolated; cd -

# and source source our ROS base and overlay workspaces
RUN echo ". /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN echo ". ~/rover/devel_isolated/setup.bash" >> ~/.bashrc

# and, boom!
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT /entrypoint.sh

