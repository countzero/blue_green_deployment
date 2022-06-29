# Debian 11.3 "Bullseye" Base Box

A guide on how to prepare an Debian 11.3 for the usage with Vagrant.

## Install VirtualBox, Vagrant and Packer

Download and install the latest versions in that order:

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://www.vagrantup.com/downloads.html)
* [Packer](https://www.packer.io/downloads.html)

**Hint:** Make sure the directory you installed Packer to is on the `PATH` variable.

## Build debian-11.2-amd64-virtualbox.json

Fire up your console at `./infrastructure/boxes/debian-11.3-amd64` and execute

```Shell
packer build debian-11.3-amd64-virtualbox.json
```

## Create a checksum

### Windows

Fire up a PowerShell console at `./infrastructure/boxes/debian-11.3-amd64` and execute

```PowerShell
$(CertUtil -hashfile debian-11.3-amd64-virtualbox.box SHA256)[1] -replace " ","" `
> debian-11.3-amd64-virtualbox-sha256.checksum
```

### Linux

Fire up a terminal at `./infrastructure/boxes/debian-11.3-amd64` and execute

```Bash
sha256sum debian-11.3-amd64-virtualbox.box | cut -d " " -f 1 \
> debian-11.3-amd64-virtualbox-sha256.checksum
```
