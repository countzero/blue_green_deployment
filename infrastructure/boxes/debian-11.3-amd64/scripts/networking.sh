#!/bin/bash -eux

#
# Configure networking.
#

# Remove DHCP leases.
rm /var/lib/dhcp/*

# Remove persistent udev rules.
rm -f /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
