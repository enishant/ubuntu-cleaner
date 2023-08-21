#!/bin/sh

# References:
# https://www.esds.co.in/kb/how-to-clean-up-ubuntu-server/
# https://www.omgubuntu.co.uk/2016/08/5-ways-free-up-space-on-ubuntu
# https://www.tecmint.com/clear-ram-memory-cache-buffer-and-swap-space-on-linux/
# https://askubuntu.com/a/1156686
# https://gist.github.com/Iman/8c4605b2b3ce8226b08a

sudo apt-get autoremove
sudo apt-get clean
sudo rm -fr /home/$USER/.cache/thumbnails/*

# Python cache clean
pip cache purge
pip3 cache purge

# sudo -u $USER composer cc
# export COMPOSER_ALLOW_SUPERUSER=1
# sudo -u root composer cc

sudo sh -c 'rm -rf /var/lib/snapd/cache/*'

# Note, we are using "echo 3", but it is not recommended in production instead use "echo 1"
LOG=/var/log/system-clear-cache.log
DATA=`date +%Y-%m-%d" "%H:%M:%S`

# Clear PageCache only.
sync; echo 1 > /proc/sys/vm/drop_caches

# Clear dentries and inodes.
sync; echo 2 > /proc/sys/vm/drop_caches

# Clear PageCache, dentries and inodes.
sync; echo 3 > /proc/sys/vm/drop_caches 

# Clear Swap Space in Linux
swapoff -a
swapon -a

echo "$DATA | Cache Cleared" >> $LOG
tail -1 $LOG

# Clean System
find /var/log -type f -name "*.gz" -delete

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

rm -rf /var/log/user.log
rm -rf /var/log/syslog
rm -rf /var/log/messages
find /var/log -type f -regex ".*\.gz$" | xargs rm -Rf
find /var/log -type f -regex ".*\.[0-9]$" | xargs rm -Rf

sudo apt-get install deborphan -y
deborphan | xargs sudo apt-get -y remove --purge
sudo apt-get remove deborphan -y
sudo apt-get autoremove -y
sudo apt-get clean -y
sleep 10
