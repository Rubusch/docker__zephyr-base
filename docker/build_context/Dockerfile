FROM debian:11 AS zephyr-base
MAINTAINER Lothar Rubusch <l.rubusch@gmail.com>
ENV DEBIAN_FRONTEND=noninteractive


################################################################################
## the USER is needed to make it available as --build-arg
## in case docker complains for a not set USER, perhaps you forgot to use --build-arg USER=$USER
ARG USER="${ENV_USER}"
ARG GID="${ENV_GID}"
ARG UID="${ENV_UID}"
ARG MY_CONFIGS="/home/$USER/configs"
ARG MY_CMAKE_VERSION="3.20.5"
ARG MY_ZEPHYR_SDK_VERSION="0.13.0"
ARG MY_ZEPHYR_SDK="zephyr-sdk-${MY_ZEPHYR_SDK_VERSION}-linux-x86_64-setup.run"
## older version
#ARG MY_ZEPHYR_SDK="zephyr-sdk-${ZEPHYR_SDK_VERSION}-setup.run"


################################################################################
## set up apt fully functional
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y --purge

## basic build and container setup
RUN apt-get install -y apt-utils
RUN apt-get install -y tzdata
RUN apt-get install -y locales
RUN apt-get install -y build-essential
RUN apt-get install -y flex
RUN apt-get install -y bison
RUN apt-get install -y libncurses5
RUN apt-get install -y udev
RUN apt-get install -y openssh-client
RUN apt-get install -y libssl-dev

## zephyr setup
RUN apt-get install -y aptitude
RUN apt-get install -y git
RUN apt-get install -y tig
RUN apt-get install -y ninja-build
RUN apt-get install -y gperf
RUN apt-get install -y ccache
RUN apt-get install -y dfu-util
RUN apt-get install -y device-tree-compiler
RUN apt-get install -y wget
RUN apt-get install -y libpython3.8
RUN apt-get install -y python3-dev
RUN apt-get install -y python3-pip
RUN apt-get install -y python3-setuptools
RUN apt-get install -y python3-tk
RUN apt-get install -y python3-wheel
RUN apt-get install -y xz-utils
RUN apt-get install -y file
RUN apt-get install -y make
RUN apt-get install -y gcc
RUN apt-get install -y gcc-multilib
RUN apt-get install -y g++-multilib
RUN apt-get install -y libsdl2-dev
RUN apt-get install -y gnutls-bin
RUN apt-get install -y usbutils
RUN apt-get install -y vim
RUN apt-get install -y screen
RUN apt-get install -y minicom
RUN apt-get install -y libpython2.7
RUN apt-get install -y sudo
RUN apt-get install -y tree
RUN apt-get install -y colordiff
RUN apt-get install -y htop


################################################################################
## local settings
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8


################################################################################
## setup user and run stuff under user
RUN groupadd -g "$GID" "$USER"
RUN useradd -m -u "$UID" -g "$GID" -s /bin/bash "$USER"
RUN usermod -a -G sudo "$USER"
RUN sed -i '/%sudo/s/.*/%sudo   ALL=NOPASSWD: ALL/' /etc/sudoers
RUN mkdir -p /usr/local
RUN chown -R "${USER}":"${USER}" /usr/local
RUN mkdir -p /opt
RUN chown -R "${USER}":"${USER}" /opt


################################################################################
## tooling

## cmake in version 3.20+
WORKDIR "/opt"
RUN wget "https://github.com/Kitware/CMake/releases/download/v${MY_CMAKE_VERSION}/cmake-${MY_CMAKE_VERSION}.tar.gz"
RUN tar xzf cmake-*.tar.gz
WORKDIR "/opt/cmake-${MY_CMAKE_VERSION}"
RUN ./bootstrap && make && sudo make install

## zephyr
USER $USER
WORKDIR /home/$USER

## some ssl tweaks (small buffer, timeouts, etc.)
## fix for: "error: RPC failed; curl 56 GnuTLS recv error (-110):
##   The TLS connection was non-properly terminated"
RUN git config --global http.sslVerify false
RUN git config --global http.postBuffer 1048576000
RUN git config --global init.defaultBranch main

## prepare environment
RUN ln -s /usr/local /home/$USER/.local
RUN sudo chown $USER:$USER -R /usr/local
RUN mkdir -p /home/$USER/.local/bin
RUN sudo chown $USER:$USER -R /home/$USER/.local

## setup west in 'zephyrproject'
RUN export PATH=/home/${USER}/.local/bin:${PATH}
RUN pip3 install --user -U west
RUN test -d /home/${USER}/zephyrproject/.west || west init zephyrproject

USER $USER
WORKDIR /home/$USER/zephyrproject
RUN west update
RUN west zephyr-export
RUN pip3 install --user -r zephyr/scripts/requirements.txt

## folder 'zephyr' will be mounted, so better remove this, to avoid
## some confusion with overlays...
RUN rm -rf /home/$USER/zephyrproject/zephyr

## zephyr SDK
## NB: the following typically fails with 'Error in the pull function'
## behind a tunneled connection
WORKDIR "/home/$USER"
RUN wget "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${MY_ZEPHYR_SDK_VERSION}/${MY_ZEPHYR_SDK}"
RUN chmod +x "${MY_ZEPHYR_SDK}"
RUN ./"${MY_ZEPHYR_SDK}" -- -d "/usr/local/zephyr-sdk-${MY_ZEPHYR_SDK_VERSION}"
RUN rm -rf "${MY_ZEPHYR_SDK}"

## (opt) udev rules for later flashing
RUN sudo cp ~/zephyr-sdk-${MY_ZEPHYR_SDK_VERSION}/sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d
RUN cd /home/$USER && sudo udevadm control --reload

## (opt) set up 'unset preset flags' command script
RUN echo 'unset CFLAGS CXXFLAGS' | sudo tee -a /etc/profile.d/unset_cflags.sh


################################################################################
## get sources
USER ${USER}
WORKDIR /home/${USER}

## prepare paths
RUN mkdir -p /home/${USER}/zephyrproject

## bash config
RUN rm -f /home/$USER/.bashrc && ln -s ${MY_CONFIGS}/.bashrc /home/$USER/

## vim config
RUN rm -f /home/$USER/.vimrc && ln -s ${MY_CONFIGS}/.vimrc /home/$USER/

## emacs config
RUN rm -f /home/$USER/.emacs && ln -s ${MY_CONFIGS}/.emacs /home/$USER/

## user
RUN echo "export USER=${USER}" >> /home/$USER/.profile

## ssh preparations
RUN mkdir -p /home/$USER/.ssh


################################################################################
## command mode
USER $USER
COPY *.sh /usr/local/bin/
CMD ["/bin/cat", "/etc/issue"]
