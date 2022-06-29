#!/bin/bash -eux

#
# Clean up to minimize the base box size.
#

# Remove unnecessary packages and clean up.
apt-get --yes --purge remove linux-headers-$(uname -r) build-essential
apt-get --yes --purge autoremove
apt-get --yes clean

# Remove history file
unset HISTFILE
