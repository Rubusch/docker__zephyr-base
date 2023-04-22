[![CircleCI](https://dl.circleci.com/status-badge/img/gh/Rubusch/docker__zephyr-base/tree/zephyr3%2E3.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/Rubusch/docker__zephyr-base/tree/zephyr3%2E3)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)


# Zephyr Base

Base container for zephyr projects.  


## Tools Needed

```
$ sudo apt-get install -y libffi-dev libssl-dev
$ sudo apt-get install -y python3-dev
$ sudo apt-get install -y python3 python3-pip
$ pip3 install docker-compose
```
Make sure, ``~/.local`` is within ``$PATH`` or re-link e.g. it to ``/usr/local``.  


## Build

```
$ cd ./docker
$ echo "UID=$(id -u)" > .env
$ echo "GID=$(id -g)" >> .env
$ docker-compose build
```


## Usage

Build target  
```
$ docker-compose -f ./docker-compose.yml run --rm zephyr3.3
```

Login to develop, e.g. for the SiFive HiFive1 Rev B  
```
$ docker-compose -f ./docker-compose.yml run --rm zephyr3.3 /bin/bash
docker$ cd ./zephyrproject/zephyr
docker$ west build -b hifive1_revb samples/basic/blinky
docker$ west flash
```

**!!!Make sure the device is plugged (/dev/ttyACM0 exists) before entering the container!!!**  

NB: Appending ``--privileged`` is not _safe_! Mainly this is used for such things as connecting the USB (SEGGER) the easiest way possible.  

NB: Append ``/bin/bash`` to enter the current container for debugging  
