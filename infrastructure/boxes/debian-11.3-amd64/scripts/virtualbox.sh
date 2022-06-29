#!/bin/bash -eux

#
# Install the VirtualBox Guest Additions.
#
# @see https://www.vagrantup.com/docs/boxes/base.html
#

# Install the VirtualBox guest additions.
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
VBOX_ISO=VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop $VBOX_ISO /mnt
yes|sh /mnt/VBoxLinuxAdditions.run
umount /mnt

# Clean up VirtualBox guest additions.
rm $VBOX_ISO
