##############################################################################
# Build WSL2 kernel with usb-storage support
# menuconfig -> Device Drivers --> USB support ---> USB Mass Storage support
##############################################################################
sudo apt update && sudo apt upgrade -y && sudo apt install -y build-essential flex bison libgtk2.0-dev libelf-dev libncurses-dev autoconf libudev-dev libtool zip unzip v4l-utils libssl-dev python3-pip cmake git iputils-ping net-tools dwarves
sudo mkdir /usr/src/$(uname -r)
cd /usr/src/$(uname -r)
sudo git clone https://github.com/microsoft/WSL2-Linux-Kernel.git
cd WSL2-Linux-Kernel
sudo cp /proc/config.gz config.gz
sudo gunzip config.gz
sudo mv config .config
sudo make menuconfig
sudo make -j$(nproc)
sudo make modules_install -j$(nproc)
sudo make install -j$(nproc)
sudo mkdir /mnt/c/sources/
sudo cp -rf vmlinux /mnt/c/sources/
##############################################################################

