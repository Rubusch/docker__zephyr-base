#!/bin/sh -e

export MY_ZEPHYR_SDK_VERSION="0.16.0"
export ZEPHYR_BRANCH="main"

export MY_CONFIGS="/home/$USER/configs"
export MY_ZEPHYR_SDK="zephyr-sdk-${MY_ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz"
export MY_ZEPHYR_DIR="/home/$USER/zephyrproject"
export MY_ZEPHYR_SDK_DIR="/home/$USER/zephyr-sdk-${MY_ZEPHYR_SDK_VERSION}"

## permissions
00_defenv.sh "${MY_ZEPHYR_DIR}"

## initial clone zephyr sources
if [ ! -e "${MY_ZEPHYR_DIR}/.west" ]; then
	cd "/home/$USER"
	pip install west
	west init ${MY_ZEPHYR_DIR}
fi

## set to branch
cd ${MY_ZEPHYR_DIR}/zephyr
git checkout ${ZEPHYR_BRANCH}

## update zephyr base
cd ${MY_ZEPHYR_DIR}
west update
west zephyr-export
pip install -r ${MY_ZEPHYR_DIR}/zephyr/scripts/requirements.txt

echo "READY."
