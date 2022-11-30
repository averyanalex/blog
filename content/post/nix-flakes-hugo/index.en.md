---
title: "Nix flakes for Hugo site"
description: "How to use nix to build and deploy hugo-based website"
date: 2022-11-29T15:31:37+03:00
image: hugo-build-nix.png
tags: [NixOS]
---

## Advantages of managing Hugo website with Nix.

- Reproducible builds: Nix allows you to reproducible build your Hugo website across multiple machines.
- Dependency management: Nix makes it easy to manage theme, other dependencies and even Hugo itself for your website.
- Easy deployment: just set root of your nginx virtualHost to site's package.

## Setup your site.

### Write flake.nix.

This is an example of flake.nix I use for this blog, adapt it for your needs.

```nix
{
  description = "AveryanAlex's personal blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Import theme
    stack = {
      url = github:CaiJimmy/hugo-theme-stack;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, stack }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        blog = pkgs.stdenv.mkDerivation {
          name = "blog";
          # Exclude themes and public folder from build sources
          src = builtins.filterSource
            (path: type: !(type == "directory" &&
              (baseNameOf path == "themes" ||
                baseNameOf path == "public")))
            ./.;
          # Link theme to themes folder and build
          buildPhase = ''
            mkdir -p themes
            ln -s ${stack} themes/stack
            ${pkgs.hugo}/bin/hugo --minify
          '';
          installPhase = ''
            cp -r public $out
          '';
          meta = with pkgs.lib; {
            description = "AveryanAlex's personal blog";
            platforms = platforms.all;
          };
        };
      in
      {
        packages = {
          blog = blog;
          default = blog;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ hugo ];
          # Link theme to themes folder
          shellHook = ''
            mkdir -p themes
            ln -sf ${stack} themes/stack
          '';
        };
      });
}
```

### Setup direnv.

```shell
echo use flake >> .envrc
echo .direnv >> .gitignore
direnv allow
```

### Add result to .gitignore.

Result folder is a symlink to built website created by `nix build` command.

```shell
echo result >> .gitignore
```

## Preview and build.

Run development server:

```shell
hugo server -D
```

Build production release with nix:

```shell
nix build
```

## Deploying to nginx webserver.

Now we will create nginx virtualHost config for the site.

Add website to server's flake inputs:

```nix
{
  inputs.blog.url = "github:averyanalex/blog";
}
```

Setup nginx virtualHost to serve your site:

```nix
{ inputs, ... }:
{
  services.nginx.virtualHosts."averyan.ru" = {
    # TODO: same config for any arch
    root = inputs.blog.defaultPackage.x86_64-linux;
    useACMEHost = "averyan.ru";
    forceSSL = true;
  };
}
```
