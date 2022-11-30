---
title: "Install NixOS from RescueCD"
# description: "Install Nixos From Rescuecd"
date: 2022-11-30T22:44:34+03:00
# image: image.png
tags: [NixOS]
draft: true
---

## Connect to the internet

```shell
/etc/init.d/NetworkManager stop
ip a add 185.112.83.99/32 dev eth0
ip r add 10.0.0.1 dev eth0
ip r add default via 10.0.0.1
```

## Install Nix

```shell
mkdir /nix
groupadd nixbld
useradd nixbld0
usermod -aG nixbld nixbld0
# -k because of ssl problems
sh <(curl -L https://nixos.org/nix/install -k) --no-daemon
# some cmd to activate env
nix-env -iA nixpkgs.nixos-install-tools
```

## Prepare disks

1. 2M BIOS BOOT
2. 256M FAT32 /boot
3. All ext4 /

## Install system

```shell
nixos-install --flake foo#bar
```
