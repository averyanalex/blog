---
title: "NixOS native optimizations"
description: "Turn your NixOS setup into Gentoo"
date: 2022-08-29T23:11:57+03:00
image: htop-gcc.png
tags: [NixOS]
draft: true
---

## Add your cpu architecture to system features

Don't forget to change `haswell` to your cpu's microarchitecture! You can get
list on [gcc's docs](https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html).

```nix
nix.settings.system-features = [
  "big-parallel"
  "kvm"
  "nixos-test"
  "gccarch-haswell"
];
```

Rebuild to apply features changes. Now you can go to the next step.

## Set -march and -mtune

```nix
nixpkgs.localSystem = {
  gcc.arch = "haswell";
  gcc.tune = "haswell";
  system = "x86_64-linux";
};
```

## Disable tests

If you don't want to spend time for tests (all packages are already tested by
Hydra and likely won't break because of optimizations), add the following to
your config:

```nix
nixpkgs.overlays = [
  (final: prev: {
    stdenv = prev.stdenvAdapters.addAttrsToDerivation
      {
        doCheck = false;
      }
      prev.stdenv;
  })
];
```

## Final config

```nix
let
  arch = "haswell";
in
{
  nix.settings.system-features = [
    # "benchmark"
    "big-parallel"
    "kvm"
    "nixos-test"
    "gccarch-${arch}"
  ];

  nixpkgs.localSystem = {
    gcc.arch = arch;
    gcc.tune = arch;
    system = "x86_64-linux";
  };

  nixpkgs.overlays = [
    (final: prev: {
      stdenv = prev.stdenvAdapters.addAttrsToDerivation
        {
          doCheck = false;
        }
        prev.stdenv;
    })
  ];
}
```
