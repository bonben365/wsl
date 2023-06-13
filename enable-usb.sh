######################
# Build WSL2 kernel with usb-storage support
# menuconfig -> Device Drivers --> USB support ---> USB Mass Storage support
######################
sudo apt update && sudo apt upgrade -y && sudo apt install -y build-essential flex bison libgtk2.0-dev libelf-dev libncurses-dev autoconf libudev-dev libtool zip unzip v4l-utils libssl-dev python3-pip cmake git iputils-ping net-tools dwarves
sudo mkdir /usr/src
cd /usr/src
sudo git clone -b linux-msft-wsl-${uname -r} https://github.com/microsoft/WSL2-Linux-Kernel.git ${uname -r}-microsoft-standard && cd ${uname -r}-microsoft-standard
sudo cp /proc/config.gz config.gz
sudo gunzip config.gz
sudo mv config .config
sudo make menuconfig
sudo make -j$(nproc)
sudo make modules_install -j$(nproc)
sudo make install -j$(nproc)
sudo cp -rf vmlinux /mnt/c/sources/