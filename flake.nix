{
  description = "Libregig - band management app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    ruby-nix.url = "github:inscapist/ruby-nix/1f3756f8a713171bf891b39c0d3b1fe6d83a4a63";
    flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";
  };

  outputs =
    {
      self,
      nixpkgs,
      ruby-nix,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ ruby-nix.overlays.ruby ];
        };
        rubyNix = ruby-nix.lib pkgs;

        inherit
          (rubyNix {
            name = "libregig";
            gemset = ./gemset.nix;
            ruby = pkgs.ruby_3_2;
          })
          env
          ruby
          ;

        commonDeps = import ./nix/dependencies.nix { inherit pkgs env ruby; };
      in
      {
        devShells = rec {
          default = dev;
          dev = pkgs.mkShell {
            buildInputs = commonDeps;
            env = {
              BUNDLE_PATH = "$GEM_HOME";
              TAILWINDCSS_INSTALL_DIR = "./node_modules/.bin";
            };
          };
        };

        checks = {
          basic-rails-test = import ./nix/tests/basic-rails.nix { inherit pkgs env ruby; };
        };
      }
    );
}
