{
  description = "A simple ruby app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ruby-nix.url = "github:inscapist/ruby-nix";
    flake-utils.url = "github:numtide/flake-utils";
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
            name = "simple-ruby-app";
            gemset = ./gemset.nix;
            ruby = pkgs.ruby_3_2;
          })
          env
          ruby
          ;
      in
      {
        devShells = rec {
          default = dev;
          dev = pkgs.mkShell {
            buildInputs = [
              env
              ruby
              pkgs.nodejs_22
              pkgs.glibc
              pkgs.nodePackages_latest.tailwindcss
              pkgs.libyaml
              pkgs.pkg-config
              pkgs.ruby_3_2
              pkgs.rubyPackages_3_2.concurrent-ruby
              pkgs.rubyPackages_3_2.htmlbeautifier
              pkgs.rubyPackages_3_2.nokogiri
              pkgs.rubyPackages_3_2.psych
              pkgs.rubyPackages_3_2.rails
              pkgs.rubyPackages_3_2.rugged
              pkgs.rubyPackages_3_2.sassc
              pkgs.rubyPackages.execjs
              pkgs.sqlite
              pkgs.xclip

            ];
            env = {
              BUNDLE_PATH = "$GEM_HOME";
              TAILWINDCSS_INSTALL_DIR = "./node_modules/.bin";
            };
          };
        };
      }
    );
}
