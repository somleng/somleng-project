#!/bin/bash -x

sudo apt-get -y update
sudo apt-get install -y xz-utils devscripts cowbuilder git
sudo echo "ALLOWUNTRUSTED=yes" >> /etc/pbuilderrc

# Checkout source
# sudo ./debian/util.sh build-all -cbullseye -mquicktest -aamd64
