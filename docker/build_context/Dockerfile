################################################################################
## ATTENTION: standalone container
##
################################################################################
FROM ubuntu:20.04 AS zephyr
MAINTAINER Lothar Rubusch <l.rubusch@gmail.com>
ENV DEBIAN_FRONTEND=noninteractive

################################################################################
## environment
ARG USER="${USER}"
ARG UID="${UID}"
ARG GID="${GID}"

ENV MY_ZEPHYR_SDK_VERSION="0.16.0"

ENV MY_CONFIGS="/home/$USER/configs"
ENV MY_ZEPHYR_SDK="zephyr-sdk-${MY_ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz"
ENV MY_ZEPHYR_DIR="/home/$USER/zephyrproject"
ENV MY_ZEPHYR_SDK_DIR="/home/$USER/zephyr-sdk-${MY_ZEPHYR_SDK_VERSION}"

################################################################################
## set up apt fully functional
USER root
RUN apt-get update && apt-get autoremove -y --purge

## basic build and container setup
RUN apt-get install -y \
	apt-utils \
	tzdata \
	locales \
	build-essential \
	flex \
	bison \
	libncurses5 \
	udev \
	openssh-client \
	sudo \
	libssl-dev

### zephyr setup
RUN apt-get install -y --no-install-recommends \
	git \
	cmake \
	ninja-build \
	gperf \
	ccache \
	dfu-util \
	device-tree-compiler \
	wget \
	python3-dev \
	python3-pip \
	python3-setuptools \
	python3-tk \
	python3-wheel \
	xz-utils \
	file \
	make \
	gcc \
	gcc-multilib \
	g++-multilib \
	libsdl2-dev \
	libmagic1

## recommended python venv
RUN apt-get install -y \
	python3-venv

## development tools
RUN apt-get install -y \
	aptitude \
	tig \
	make \
	gcc \
	libsdl2-dev \
	gnutls-bin \
	usbutils \
	cmake \
	vim \
	vim-addon-manager \
	vim-youcompleteme \
	emacs \
	emacs-goodies-el \
	emacs-goodies-extra-el \
	exuberant-ctags \
	screen \
	mc \
	minicom \
	libpython2.7 \
	tree \
	colordiff \
	htop

################################################################################
## local settings
USER root
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

################################################################################
## user settings
USER root
RUN groupadd -g "$GID" "$USER"
RUN useradd -m -u "$UID" -g "$GID" -s /bin/bash "$USER"
RUN echo "$USER  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN mkdir -p /usr/local
RUN chown -R "${USER}":"${USER}" /usr/local
RUN mkdir -p /opt
RUN chown -R "${USER}":"${USER}" /opt

################################################################################
## configs and mount points
USER "${USER}"
WORKDIR "/home/${USER}"

## prepare paths
RUN mkdir -p /home/${USER}/configs
RUN mkdir -p /home/${USER}/zephyrproject

## bash config
RUN rm -f /home/$USER/.bashrc && ln -s ${MY_CONFIGS}/.bashrc /home/$USER/

## vim config
RUN rm -f /home/$USER/.vimrc && ln -s ${MY_CONFIGS}/.vimrc /home/$USER/
RUN vim-addon-manager install youcompleteme

## emacs config
RUN rm -f /home/$USER/.emacs && ln -s ${MY_CONFIGS}/.emacs /home/$USER/

## gitconfig (adjustable for patching)
RUN rm -f /home/$USER/.gitconfig && ln -s ${MY_CONFIGS}/.gitconfig /home/$USER/

## user
RUN echo "export USER=${USER}" >> /home/$USER/.profile

## ssh preparations
RUN mkdir -p /home/$USER/.ssh

################################################################################
## zephyr SDK
USER "${USER}"
WORKDIR "/home/${USER}"

## some ssl tweaks (small buffer, timeouts, etc.)
## fix for: "error: RPC failed; curl 56 GnuTLS recv error (-110):
##   The TLS connection was non-properly terminated"
#RUN git config --global http.sslVerify false
#RUN git config --global http.postBuffer 1048576000
#RUN git config --global init.defaultBranch main

## prepare environment
RUN ln -s /usr/local /home/$USER/.local
RUN sudo chown $USER:$USER -R /usr/local
RUN mkdir -p /home/$USER/.local/bin
RUN sudo chown $USER:$USER -R /home/$USER/.local

## setup west in 'zephyrproject'
RUN export PATH=/home/${USER}/.local/bin:${PATH}

################################################################################
## https://docs.zephyrproject.org/latest/develop/getting_started/index.html 
##
USER "${USER}"
WORKDIR "/home/${USER}"
RUN wget https://apt.kitware.com/kitware-archive.sh
RUN sudo bash kitware-archive.sh

## install zephyr
RUN python3 -m venv ${MY_ZEPHYR_DIR}/.venv
RUN source ${MY_ZEPHYR_DIR}/.venv/bin/activate
RUN pip install west
RUN west init ${MY_ZEPHYR_DIR}

WORKDIR ${MY_ZEPHYR_DIR}
RUN west update
RUN west zephyr-export
RUN pip install -r ${MY_ZEPHYR_DIR}/zephyr/scripts/requirements.txt

################################################################################
## zephyr SDK
##
USER "${USER}"
WORKDIR "/home/$USER"
## NB: the following typically fails with 'Error in the pull function'
## behind a tunneled connection
RUN wget "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${MY_ZEPHYR_SDK_VERSION}/${MY_ZEPHYR_SDK}"
RUN tar xvf "${MY_ZEPHYR_SDK}"

WORKDIR "${MY_ZEPHYR_SDK_DIR}"
RUN chmod +x ./setup.sh
RUN ./setup.sh

################################################################################
## SEGGER, JLink tools
## (approach taken from: https://github.com/Scottapotamas/docker-riscv-zephyr/blob/master/Dockerfile)
USER "${USER}"
WORKDIR "/home/$USER"

RUN wget -q --post-data 'accept_license_agreement=accepted&non_emb_ctr=confirmed&submit=Download+software' https://www.segger.com/downloads/flasher/JLink_Linux_x86_64.deb
RUN sudo apt-get install -y udev libxcb-render0 libxcb-render-util0 libxcb-shape0 libxcb-icccm4 libxcb-keysyms1 libxcb-image0 libxkbcommon-x11-0
RUN sudo dpkg -i ./JLink_Linux_x86_64.deb || true  ## ignore "Failed to reload udevadm rules, retrying..." errors

## we're inside docker
##RUN sudo cp ~/zephyr-sdk-${MY_ZEPHYR_SDK_VERSION}/sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d
##RUN sudo udevadm control --reload

## (opt) set up 'unset preset flags' command script
#RUN echo 'unset CFLAGS CXXFLAGS' | sudo tee -a /etc/profile.d/unset_cflags.sh

################################################################################
## command mode
USER "${USER}"
WORKDIR "/home/${USER}"
COPY *.sh /usr/local/bin/
CMD ["/bin/cat", "/etc/issue"]
