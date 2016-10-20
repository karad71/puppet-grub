[![Build Status](https://travis-ci.org/icann-dns/puppet-grub.svg?branch=master)](https://travis-ci.org/icann-dns/puppet-grub)
[![Puppet Forge](https://img.shields.io/puppetforge/v/icann/grub.svg?maxAge=2592000)](https://forge.puppet.com/icann/grub)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/icann/grub.svg?maxAge=2592000)](https://forge.puppet.com/icann/grub)
# grub

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with grub](#setup)
    * [What grub affects](#what-grub-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with grub](#beginning-with-grub)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Manage client and server](#manage-client-and-server)
    * [Ansible client](#grub-client)
    * [Ansible Server](#grub-server)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module installs is used to manage grub, specificly we wanted a way to secure the grub menu entry which i did not find at the time.  In future we will look to migrate to [herculesteam-augeasproviders_grub](https://forge.puppet.com/herculesteam/augeasproviders_grub)

## Setup

### What grub affects

* Manages the grub menu item and superusers

### Setup Requirements

* puppetlabs-stdlib 4.12.0

### Beginning with grub

just add the grub class.

```puppet
class {'::grub' }
```

## Usage

### Add an user and password and protectect edit functions

```puppet
class {'::grub' 
  user => 'test',
  password => grub.pbkdf2.sha512.10000.$SOMHEHASH,
}
```

of with hiera

```yaml
grub::user: test
grup::password: grub.pbkdf2.sha512.10000.$SOMHEHASH
```

## Reference

### Classes

#### Public Classes

* [`grub`](#class-grub)

#### Class: `grub`

Main class, includes all other classes

##### Parameters 

* `user` (Optional[String]): The user to secure grub.  If the username and password are present then by default they will be required to edit grub config at boot
* `password` (Optional[String]): The password to secure grub 
* `protect_boot` (Boolean, Default: false): If true also require the username and password toboot the system
* `protect_advanced` (Boolean, Default: false): If true also require the username and password to access the advanced menu

## Limitations

This module is tested on Ubuntu 12.04, and 14.04
