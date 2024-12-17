{
  description = "Libregig - band management app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    ruby-nix.url = "github:inscapist/ruby-nix/1f3756f8a713171bf891b39c0d3b1fe6d83a4a63";
    flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";

    bundix = {
      url = "github:inscapist/bundix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bob-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    bob-ruby.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      ruby-nix,
      flake-utils,
      bundix,
      bob-ruby,
    }:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ bob-ruby.overlays.ruby ];
        };
        rubyNix = ruby-nix.lib pkgs;
        gemset = import ./gemset.nix;
        ruby = pkgs."ruby-3.3.6";
        bundixcli = bundix.packages.${system}.default;

        bundleLock = pkgs.writeShellScriptBin "bundle-lock" ''
          export BUNDLE_PATH=vendor/bundle
          bundle lock
        '';
        bundleUpdate = pkgs.writeShellScriptBin "bundle-update" ''
          export BUNDLE_PATH=vendor/bundle
          bundle lock --update
        '';
      in
      rec {
        inherit
          (rubyNix {
            inherit gemset ruby;
            name = "libregig";
          })
          env
          ;

        devShells = rec {
          default = dev;
          dev = pkgs.mkShell {
            buildInputs =
              [
                env
                bundixcli
                bundleLock
                bundleUpdate
              ]
              ++ (with pkgs; [
                yarn
                rufo
                # more packages here
              ]);
          };
        };

        packages = {
          inherit env ruby;
          default = env;
        };

        checks = {
          service-test = import ./nix/tests/service.nix {
            inherit pkgs self;
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
          makeBaseServiceConfig = name: {
            User = "libregig-${name}";
            Group = "libregig-${name}";
            StandardOutput = "journal";
            StandardError = "journal";

            # Security settings
            ProtectSystem = "strict";
            ProtectHome = true;
            PrivateTmp = true;
            PrivateDevices = true;
            PrivateUsers = true;
            ProtectClock = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectControlGroups = true;
            RestrictAddressFamilies = [
              "AF_UNIX"
              "AF_INET"
              "AF_INET6"
              "AF_NETLINK"
            ];
            RestrictNamespaces = true;
            LockPersonality = true;
            MemoryDenyWriteExecute = false;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            RemoveIPC = true;
            PrivateMounts = true;
          };

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

              rm -rf "/run/libregig-${name}"
              mkdir "/run/libregig-${name}"

              # copy repo
              cp -r "${./.}/." "/run/libregig-${name}"

              # asset builds
              rm -rf "/run/libregig-${name}/app/assets/builds"
              mkdir -p "/var/lib/libregig-${name}/app/assets/builds"
              mkdir -p "/run/libregig-${name}/app/assets"
              ln -s "/var/lib/libregig-${name}/app/assets/builds" "/run/libregig-${name}/app/assets/builds"

              # clear storage
              rm -rf "/run/libregig-${name}/storage"
              mkdir -p "/var/lib/libregig-${name}/storage"
              ln -s "/var/lib/libregig-${name}/storage" "/run/libregig-${name}/storage"

              # clear log
              rm -rf "/run/libregig-${name}/log"
              mkdir -p "/var/lib/libregig-${name}/log"
              ln -s "/var/lib/libregig-${name}/log" "/run/libregig-${name}/log"

              # clear tmp
              rm -rf "/run/libregig-${name}/tmp"
              mkdir -p "/var/lib/libregig-${name}/tmp"
              ln -s "/var/lib/libregig-${name}/tmp" "/run/libregig-${name}/tmp"

              # link env
              rm -f "/run/libregig-${name}/.env"
              ln -s "/var/lib/libregig-${name}/.env" "/run/libregig-${name}/.env"

              chown -R libregig-${name}:libregig-${name} /var/lib/libregig-${name}
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
                  serviceConfig = makeBaseServiceConfig name // {
                    Type = "simple";
                    CacheDirectory = "libregig-${name}";
                    RuntimeDirectory = "libregig-${name}";
                    StateDirectory = "libregig-${name}";
                    WorkingDirectory = "/run/libregig-${name}";
                    ExecStart = "+${
                      self.packages.${pkgs.system}.env
                    }/bin/bundle exec rails server -p ${toString instanceCfg.port}";
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
                  serviceConfig = makeBaseServiceConfig name // {
                    Type = "oneshot";
                    ExecStart = "+${makeSetupScript name}/bin/libregig-setup";
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
                  serviceConfig = makeBaseServiceConfig name // {
                    Type = "oneshot";
                    WorkingDirectory = "/run/libregig-${name}";
                    ExecStart = "+${self.packages.${pkgs.system}.env}/bin/rails db:migrate";
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
