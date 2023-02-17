# Blue-Green Deployment

This is a playground to explore the concept of [blue-green deployments](https://en.wikipedia.org/wiki/Blue-green_deployment) in the context of Docker containers.

## Introduction

### Standards

Please adhere to [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html) and the [Gitflow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) in this project.

## Installation

### Install Git, VirtualBox and Vagrant

Download and install the latest version in that order from:

* [Git](https://git-scm.com/downloads)
* [VirtualBox](https://download.virtualbox.org/virtualbox)
* [Vagrant](https://releases.hashicorp.com/vagrant)

### Clone the repository from GitHub

Clone the repository to a nice place on your machine via:

```Shell
git clone git@github.com:countzero/blue_green_deployment.git
```

### Create the development environment

Fire up your console at the location you cloned the repository to. Create the virtual development machine:

```Shell
vagrant up
```

## Usage

### Application

The application should become available at:

 - http://10.0.0.50

### Deployment

Execute the [deploy.bash](./application/deploy.bash) script to make a zero downtime deployment:

```Shell
vagrant ssh -- -t "/bin/bash -l -c 'cd ~/application; sudo ./deploy.bash'"
```
