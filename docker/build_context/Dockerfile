FROM debian:11 AS zephyr-base
MAINTAINER Lothar Rubusch <l.rubusch@gmail.com>
ENV DEBIAN_FRONTEND=noninteractive
## FIXME: debian:11 on RPI4 shows weird keying issues,
## current quickfix on RPI4: going back to debian:10
## To fix this, you'll need to make sure your Docker version is newer than
## 19.03.9, and that you have a libseccomp version of 2.4.2 or higher
## (which isn't available in either buster or buster-backports right now,
## unfortunately). Thus cannot build debian:11 container on RPI4


################################################################################
## environment
ARG USER="${USER}"

ENV MY_CONFIGS="/home/$USER/configs"
ENV MY_CMAKE_VERSION="3.20.5"
ENV MY_ZEPHYR_SDK_VERSION="0.13.1"
ENV MY_ZEPHYR_SDK="zephyr-sdk-${MY_ZEPHYR_SDK_VERSION}-linux-x86_64-setup.run"

## older version
#ENV MY_ZEPHYR_SDK="zephyr-sdk-${ZEPHYR_SDK_VERSION}-setup.run"


################################################################################
## set up apt fully functional
RUN apt-get update
RUN apt-get clean

## basic build and container setup
RUN apt-get install -y apt-utils \
	tzdata \
	locales \
	build-essential \
	flex \
	bison \
	libncurses5 \
	udev \
	openssh-client \
	libssl-dev

## zephyr setup
RUN apt-get install -y aptitude \
	git \
	tig \
	ninja-build \
	gperf \
	ccache \
	dfu-util \
	device-tree-compiler \
	wget \
	libpython3.8 \
	gcc-multilib \
	g++-multilib \
	python3-dev \
	python3-pip \
	python3-setuptools \
	python3-tk \
	python3-wheel \
	xz-utils \
	file \
	make \
	gcc \
	libsdl2-dev \
	gnutls-bin \
	usbutils \
	vim \
	screen \
	minicom \
	libpython2.7 \
	sudo \
	tree \
	colordiff \
	htop


################################################################################
## local settings
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8


################################################################################
## user settings
RUN useradd -m -s /bin/bash "$USER"
RUN usermod -a -G sudo "$USER"
RUN sed -i '/%sudo/s/.*/%sudo   ALL=NOPASSWD: ALL/' /etc/sudoers
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

## emacs config
RUN rm -f /home/$USER/.emacs && ln -s ${MY_CONFIGS}/.emacs /home/$USER/

## user
RUN echo "export USER=${USER}" >> /home/$USER/.profile

## ssh preparations
RUN mkdir -p /home/$USER/.ssh


################################################################################
## tooling

## cmake in version 3.20+
WORKDIR "/opt"
RUN wget "https://github.com/Kitware/CMake/releases/download/v${MY_CMAKE_VERSION}/cmake-${MY_CMAKE_VERSION}.tar.gz"
RUN tar xzf cmake-*.tar.gz
WORKDIR "/opt/cmake-${MY_CMAKE_VERSION}"
RUN ./bootstrap && make && sudo make install


################################################################################
## zephyr SDK
USER "${USER}"
WORKDIR "/home/${USER}"

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

USER "${USER}"
WORKDIR /home/$USER/zephyrproject
RUN west update
RUN west zephyr-export
RUN pip3 install --user -r zephyr/scripts/requirements.txt

## (1/2) use zephyr sources to install python requirements, then remove it again (will be mounted from outside)
RUN rm -rf /home/$USER/zephyrproject/zephyr

## -> github clone here

## (2/2) 'zephyr' will be mounted, so better remove this, to avoid some confusion with overlays...
#RUN rm -rf /home/$USER/zephyrproject/zephyr

WORKDIR "/home/${USER}"
USER "${USER}"

## zephyr SDK
## NB: the following typically fails with 'Error in the pull function'
## behind a tunneled connection
RUN wget "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${MY_ZEPHYR_SDK_VERSION}/${MY_ZEPHYR_SDK}"
RUN chmod +x "${MY_ZEPHYR_SDK}"
RUN ./"${MY_ZEPHYR_SDK}" -- -d "/usr/local/zephyr-sdk-${MY_ZEPHYR_SDK_VERSION}"
RUN rm -rf "${MY_ZEPHYR_SDK}"

## SEGGER, JLink tools
## (approach taken from: https://github.com/Scottapotamas/docker-riscv-zephyr/blob/master/Dockerfile)
RUN wget -q --post-data 'accept_license_agreement=accepted&non_emb_ctr=confirmed&submit=Download+software' https://www.segger.com/downloads/flasher/JLink_Linux_x86_64.deb
RUN sudo apt-get install -y udev libxcb-render0 libxcb-render-util0 libxcb-shape0 libxcb-icccm4 libxcb-keysyms1 libxcb-image0 libxkbcommon-x11-0
RUN sudo dpkg -i ./JLink_Linux_x86_64.deb || true  ## ignore "Failed to reload udevadm rules, retrying..." errors

## we're inside docker
#RUN sudo cp ~/zephyr-sdk-${MY_ZEPHYR_SDK_VERSION}/sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d
#RUN sudo udevadm control --reload

## (opt) set up 'unset preset flags' command script
RUN echo 'unset CFLAGS CXXFLAGS' | sudo tee -a /etc/profile.d/unset_cflags.sh


################################################################################
## command mode
USER "${USER}"
WORKDIR "/home/${USER}"
COPY *.sh /usr/local/bin/
CMD ["/bin/cat", "/etc/issue"]
