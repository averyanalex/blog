{
  description = "AveryanAlex's personal blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

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
          src = builtins.filterSource
            (path: type: !(type == "directory" && (baseNameOf path == "themes" || baseNameOf path == "public")))
            ./.;
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
          shellHook = ''
            mkdir -p themes
            ln -sf ${stack} themes/stack
          '';
        };
      });
}
