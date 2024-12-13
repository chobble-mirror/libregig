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
    (flake-utils.lib.eachDefaultSystem (
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
          rack-test = import ./nix/tests/rack-service.nix { inherit pkgs env ruby; };
          service-test = import ./nix/tests/service.nix { inherit pkgs env ruby; };
        };
      }
    ))
    // {
      nixosModules.default =
        {
          pkgs,
          lib,
          config,
          ...
        }:
        {
          options = {
            services.libregig = {
              enable = lib.mkEnableOption "Libregig service";
              port = lib.mkOption {
                type = lib.types.port;
                default = 3000;
                description = "Port on which the Rails server will listen";
              };
              environment = lib.mkOption {
                type = lib.types.attrs;
                default = { };
                description = "Additional environment variables for the Rails application";
              };
            };
          };

          config = lib.mkIf config.services.libregig.enable {
            imports = [
              (import ./nix/modules/service.nix {
                inherit lib pkgs;
                inherit (self.packages.${pkgs.system}) env ruby;
                libregig = ./.;
                environmentConfig = {
                };
              })
            ];
          };
        };
    };
}
