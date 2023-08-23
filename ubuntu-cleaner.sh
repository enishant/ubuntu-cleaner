#!/bin/sh

UC_VERSION="1.0"
UC_FILE=/usr/local/bin/uc
if ! command -v uc > /dev/null 2>&1; then
    sudo cp uc $UC_FILE
    sudo chmod +x $UC_FILE
    if command -v uc > /dev/null 2>&1; then
    	echo "Ubuntu Cleaner installed successfully."
    	echo "To run use command as \"sudo uc\""
    else
    	echo "Something went wrong, please report issue at following url"
    	echo "https://github.com/enishant/ubuntu-cleaner/issues/new"
	fi
    exit
fi

# Thumbnails Cache
sudo rm -fr /home/$USER/.cache/thumbnails/*

# Python Cache
if command -v pip > /dev/null 2>&1; then
	pip cache purge
fi

if command -v pip3 > /dev/null 2>&1; then
	pip3 cache purge
fi

# Composer Cache
if command -v composer > /dev/null 2>&1; then
	sudo -u $USER composer cc
	export COMPOSER_ALLOW_SUPERUSER=1
	sudo -u root composer cc
fi

# Snap Cache
if command -v snapd > /dev/null 2>&1; then
	sudo sh -c 'rm -rf /var/lib/snapd/cache/*'
fi

# Swapfile
# Note, we are using "echo 3", but it is not recommended in production instead use "echo 1"
sync; echo 1 > /proc/sys/vm/drop_caches

# Clear dentries and inodes.
sync; echo 2 > /proc/sys/vm/drop_caches

# Clear PageCache, dentries and inodes.
sync; echo 3 > /proc/sys/vm/drop_caches 

# Clear Swap Space in Linux
swapoff -a
swapon -a

# System Log
find /var/log -type f -name "*.gz" -delete
find /var/log -type f -regex ".*\.gz$" | xargs rm -Rf
find /var/log -type f -regex ".*\.[0-9]$" | xargs rm -Rf
rm -rf /var/log/user.log
rm -rf /var/log/syslog
rm -rf /var/log/messages

# Journal Log
if command -v journalctl > /dev/null 2>&1; then
	journalctl --vacuum-time=10d
	sleep 2
	journalctl --vacuum-time=5d
	sleep 2
	journalctl --vacuum-time=1d
	sleep 2
	journalctl --vacuum-time=0.5d
	sleep 2
	journalctl --vacuum-time=0.3d
	sleep 2
	journalctl --vacuum-time=0.2d
	sleep 2
	journalctl --vacuum-time=0.1d
	sleep 2
	journalctl --vacuum-time=0d
fi

if ! command -v deborphan > /dev/null 2>&1; then
	sudo apt-get install deborphan -y
fi

if command -v deborphan > /dev/null 2>&1; then
	deborphan | xargs sudo apt-get -y remove --purge
	sudo apt-get remove -y deborphan
fi

# APT
sudo apt-get -y autoremove
sudo apt-get clean
sudo apt-get autoclean
