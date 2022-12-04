---
title: "Run Docker Inside Nixos Container"
# description: "Run Docker Inside Nixos Container"
date: 2022-12-04T15:19:42+03:00
# image: image.png
tags: [NixOS]
draft: true
---

## Allow keyring and bpf inside container

```nix
extraFlags = [ "--system-call-filter=@keyring" "--system-call-filter=bpf" ];
```

## Enable docker

```nix
virtualisation.docker.enable = true;
```
