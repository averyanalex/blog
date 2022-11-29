---
title: "Nix flakes for Hugo site"
description: "Using nix to build and serve hugo-based site"
date: 2022-11-29T15:31:37+03:00
---

# Writing flake.nix

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
            (path: type: !(type == "directory" && (baseNameOf path == "themes" || baseNameOf path == "public")))
            ./.;
          # Link theme to themes folder
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
            # license = licenses.cc-by-nc-sa-40;
            platforms = platforms.all;
          };
        };
      in
      {
        packages = {
          blog = blog;
        };
        defaultPackage = blog;

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

# Serving

Add blog's flake to your server's flake inputs:

```nix
{
  inputs.averyanalex-blog.url = "github:averyanalex/blog";
}
```

Setup nginx to serve your blog:

```nix
{ inputs, ... }:
{
  services.nginx.virtualHosts."averyan.ru" = {
    root = inputs.averyanalex-blog.packages.x86_64-linux.blog;
    useACMEHost = "averyan.ru";
    forceSSL = true;
    kTLS = true;
    http3 = true;
  };
}
```
