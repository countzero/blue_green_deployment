#!/bin/bash -eux

#
# Configures the machine to be accessible by Vagrant.
#
# @see https://www.vagrantup.com/docs/boxes/base.html#default-user-settings
#


# Create a system group 'admin' and assign the 'vagrant' user (created by preseed.cfg) to it.
groupadd --system admin
usermod --append --groups admin vagrant

# Set up sudo to allow no-password sudo for the 'admin' group.
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Add the public vagrant SSH key from GitHub.
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
