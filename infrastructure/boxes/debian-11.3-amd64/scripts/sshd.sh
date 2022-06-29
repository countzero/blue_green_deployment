#!/bin/bash -eux

#
# Prevent DNS resolution to speed up SSH connections.
#
# @see https://www.vagrantup.com/docs/boxes/base.html#ssh-tweaks
#

echo "UseDNS no" >> /etc/ssh/sshd_config
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
