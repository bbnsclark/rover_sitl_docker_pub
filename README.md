# ROVER SITL

> BBN TECHNOLOGES - autonomous ground vehicle platform simulation - single agent

#### Author:
Giovani Del Nero Diniz

## Getting started

The simulator images are distributed either via dockerhub or compressed file and require docker to be setup to support direct rendering.

### Recommended System Setup

 * Modern multi-core CPU, e.g. Intel Core i5
 * 8 GB of RAM
 * Discrete GPU Graphics Card with 4GB of memory, e.g. NVIDIA GTX 650
 * Ubuntu Desktop 19.10

### Prereqs

As of Docker 19.03, nvidia-docker is depricated, but docker still requires some setup to enable direct rendering support within containers.

When executing `nvidia-smi` on your host, you should receive output similar to:
```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 440.64       Driver Version: 440.64       CUDA Version: 10.2     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  GeForce GTX 1070    Off  | 00000000:01:00.0  On |                  N/A |
| N/A   48C    P0    33W /  N/A |    671MiB /  8085MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|    0      1080      G   /usr/lib/xorg/Xorg                            40MiB |
|    0      1708      G   /usr/lib/xorg/Xorg                           185MiB |
|    0      1924      G   /usr/bin/gnome-shell                         390MiB |
|    0      7354      G   /usr/lib/firefox/firefox                       1MiB |
+-----------------------------------------------------------------------------+
```

If you do not, then you need to make sure that you have hardware acceleration enabled on your host.  Particularly, you may need to (re-)install the latest NVidia drivers.  In Ubuntu, this is typcially accomplished via:

`ubuntu-drivers devices`

and if you like the recommendation, run:

`sudo ubuntu-drivers autoinstall`

Reboot and retry running `nvidia-smi`

If that still fails, you may need to disable UEFI Secure Boot with the `sudo mokutil --disable-validation` section of https://wiki.ubuntu.com/UEFI/SecureBoot/DKMS

Once you're seeing similar output in `nvidia-smi`, then you need to follow instructions at https://github.com/NVIDIA/nvidia-docker

As of Mar 2020, this required running `sudo apt install nvidia-cuda-toolkit` and then:
```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

To test that this is working, try running:

`docker run --gpus all ubuntu nvidia-smi`

If it worked, you should see similar output as running `nvidia-smi` on the host.

### DockerHub

Pull the image from dockerhub:

```
sudo docker pull radarku/rover_sitl
```

### Compressed File

```
sudo docker load --input rover_sitl.tar
```

when the image is ready, run the startup script:

```
sudo ./run.sh
```

## Running

when the initialization begins, you should have two screens open: 
 - Gazebo - loaded with a single rover placed on the lower CACTIF at Camp Shelby
 - RViz - loaded with all sensor streams ready

 If either one is not present, open the terminal used to run the previous command and run:

 ```
 ./stop.sh && ./start.sh
 ```

 that should bring up both processes correctly now. 

 ## Developing

 to develop ROS nodes and other applications on your local machine, you need to point your nodes to the master running inside the container. 
 To do that, check your docker container IP:

 ```
 ifconfig
 ```

 and check the docker IP:

 ```
 docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1 ...
```

now, we will set our MASTER_URL variable to that IP address:

```
DOCKER_IP=172.17.0.1 && export ROS_MASTER_URI=http://$DOCKER_IP:11311
```

## Support

contact maintainer at:

Giovani Del Nero Diniz
giovani.diniz@raytheon.com
