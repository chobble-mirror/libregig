{
  description = "Libregig - band management app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    ruby-nix.url = "github:inscapist/ruby-nix/1f3756f8a713171bf891b39c0d3b1fe6d83a4a63?narHash=sha256-CySXGzqycagfrWdcTwzM3Zo1MMm9uUtePYER9BvrW8s%3D";
    flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b?narHash=sha256-l0KFg5HjrsfsO/JpG%2Br7fRrqm12kzFHyUHqHCVpMMbI%3D";
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
