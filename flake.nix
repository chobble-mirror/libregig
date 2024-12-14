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
        packages = {
          inherit env ruby;
          default = env;
        };
        checks = {
          service-test = import ./nix/tests/service.nix {
            inherit
              pkgs
              env
              ruby
              self
              ;
          };
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
        let
          cfg = config.services.libregig;
          instanceOpts =
            { name, config, ... }:
            {
              options = {
                enable = lib.mkEnableOption "Libregig instance ${name}";
                port = lib.mkOption {
                  type = lib.types.port;
                  default = 3000;
                  description = "Port on which the Rails server will listen";
                };
                environment = lib.mkOption {
                  type = lib.types.attrs;
                  default = { };
                  description = "Environment variables for this instance";
                };
              };
            };

          defaultEnvironment = {
            GEM_HOME = "${self.packages.${pkgs.system}.env}";
            RAILS_ENV = "production";
            RAILS_LOG_TO_STDOUT = "1";
            RAILS_SERVE_STATIC_FILES = "1";
            SECRET_KEY_BASE = "secret_key_base";
          };

          makeSetupScript =
            name:
            pkgs.writeShellScriptBin "libregig-setup" ''
              set -e
              set -x
              mkdir -p "/var/lib/libregig-${name}"
              cp -r "${./.}/." "/run/libregig-${name}"
              cp -r "/var/lib/libregig-${name}/." "/run/libregig-${name}"
            '';
        in
        {
          options.services.libregig = {
            instances = lib.mkOption {
              type = lib.types.attrsOf (lib.types.submodule instanceOpts);
              default = { };
              description = "Libregig service instances";
            };
          };

          config = lib.mkIf (cfg.instances != { }) {
            systemd.services = lib.mkMerge [
              # Main services
              (lib.mapAttrs' (
                name: instanceCfg:
                lib.nameValuePair "libregig-${name}" {
                  description = "libregig instance ${name}";
                  environment = defaultEnvironment // instanceCfg.environment;
                  enable = instanceCfg.enable;
                  wantedBy = [ "multi-user.target" ];
                  after = [ "libregig-${name}-setup.service" ];
                  requires = [ "libregig-${name}-setup.service" ];
                  serviceConfig = {
                    User = "libregig-${name}";
                    Group = "libregig-${name}";
                    Type = "forking";
                    RuntimeDirectory = "libregig-${name}";
                    StateDirectory = "libregig-${name}";
                    WorkingDirectory = "/run/libregig-${name}";
                    ExecStart = "+${self.packages.${pkgs.system}.env}/bin/rails server -p ${toString instanceCfg.port}";
                    StandardOutput = "journal";
                    StandardError = "journal";
                  };
                }
              ) cfg.instances)

              # Setup services
              (lib.mapAttrs' (
                name: instanceCfg:
                lib.nameValuePair "libregig-${name}-setup" {
                  description = "Setup for libregig-${name}";
                  environment = defaultEnvironment // instanceCfg.environment;
                  after = [ "users.target" ];
                  before = [ "libregig-${name}.service" ];
                  requiredBy = [ "libregig-${name}.service" ];
                  serviceConfig = {
                    User = "libregig-${name}";
                    Group = "libregig-${name}";
                    Type = "oneshot";
                    ExecStart = "+${makeSetupScript name}/bin/libregig-setup";
                    StandardOutput = "journal";
                    StandardError = "journal";
                  };
                }
              ) cfg.instances)

              # Migration services
              (lib.mapAttrs' (
                name: instanceCfg:
                lib.nameValuePair "libregig-${name}-migrate" {
                  description = "Database migrations for libregig-${name}";
                  environment = defaultEnvironment // instanceCfg.environment;
                  after = [ "libregig-${name}-setup.service" ];
                  requires = [ "libregig-${name}-setup.service" ];
                  before = [ "libregig-${name}.service" ];
                  requiredBy = [ "libregig-${name}.service" ];
                  serviceConfig = {
                    User = "libregig-${name}";
                    Group = "libregig-${name}";
                    Type = "oneshot";
                    WorkingDirectory = "/run/libregig-${name}";
                    ExecStart = "+${self.packages.${pkgs.system}.env}/bin/rails db:migrate";
                    StandardOutput = "journal";
                    StandardError = "journal";
                  };
                }
              ) cfg.instances)
            ];

            users.users = lib.mapAttrs' (
              name: instanceCfg:
              lib.nameValuePair "libregig-${name}" {
                isSystemUser = true;
                group = "libregig-${name}";
              }
            ) cfg.instances;

            users.groups = lib.mapAttrs' (
              name: instanceCfg: lib.nameValuePair "libregig-${name}" { }
            ) cfg.instances;
          };
        };
    };
}
