[![CircleCI](https://circleci.com/gh/Rubusch/docker__zephyr-base.svg?style=shield)](https://circleci.com/gh/Rubusch/docker__zephyr-base)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)


# Zephyr Base

Base container for zephyr projects.  


## Tools Needed

```
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod a+x /usr/local/bin/docker-compose
```

NB: Where 1.28.6 is the latest version (currently not supported by devian/ubuntu package management)  


## Build

Preparation  

```
$ cd ./docker
$ export UID="$(id -u)"
$ export GID="$(id -g)"
$ export USER="$(whoami)"
```

Building  

```
$ docker-compose up
```

## Usage

Preparation as above, then get a shell as follows  

```
$ docker-compose -f ./docker-compose.yml run --rm zephyr-base /bin/bash
docker$ build.sh
```

Make sure the device is plugged (/dev/ttyACM0 exists)  

NB: Appending ``--privileged`` is not _safe_! Mainly this is used for such things as connecting the USB (SEGGER) the easiest way possible.  

NB: Append ``/bin/bash`` to enter the current container for debugging  


