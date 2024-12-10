{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ruby-nix.url = "github:inscapist/ruby-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      ruby-nix,
    }:
    {
      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.services.railsApps;

          fetchGitRepo =
            url: ref: hash:
            pkgs.fetchgit (
              {
                inherit url;
                rev = ref;
              }
              // lib.optionalAttrs (hash != null) {
                sha256 = hash;
              }
            );

          # Use ruby-nix overlay
          pkgsWithOverlay = import nixpkgs {
            inherit (pkgs) system;
            overlays = [ ruby-nix.overlays.ruby ];
          };

          rubyNix = ruby-nix.lib pkgsWithOverlay;
        in
        {
          # Options remain the same
          options.services.railsApps = lib.mkOption {
            type =
              with lib.types;
              attrsOf (submodule {
                options = {
                  enable = lib.mkEnableOption "Rails application service";
                  domain = lib.mkOption {
                    type = str;
                    example = "myapp.com";
                    description = "Domain name for the Rails application";
                  };
                  gitUrl = lib.mkOption {
                    type = str;
                    example = "git@github.com:username/repo.git";
                    description = "Git URL for the Rails application";
                  };
                  gitRef = lib.mkOption {
                    type = str;
                    default = "main";
                    description = "Git reference (branch, tag, or commit)";
                  };
                  useCaddy = lib.mkOption {
                    type = bool;
                    default = true;
                    description = "Whether to configure Caddy for this app";
                  };
                  sha256 = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "Optional SHA256 hash of the git repository";
                  };
                  port = lib.mkOption {
                    type = lib.types.int;
                    default = 3000;
                    description = "Port to run the Rails application on";
                  };
                };
              });
            default = { };
          };

          config = lib.mkIf (cfg != { }) {
            services.caddy.enable = lib.mkIf (lib.any (app: app.enable && app.useCaddy) (
              builtins.attrValues cfg
            )) true;

            systemd.services = lib.mkMerge (
              lib.mapAttrsToList (
                name: appConfig:
                lib.mkIf appConfig.enable {
                  "rails-${appConfig.domain}" =
                    let
                      railsApp = fetchGitRepo appConfig.gitUrl appConfig.gitRef appConfig.sha256;

                      # Use ruby-nix to create the environment
                      rubyEnv = (
                        rubyNix {
                          name = "rails-${appConfig.domain}";
                          gemset = "${railsApp}/gemset.nix";
                        }
                      );

                      startScript = pkgs.writeScriptBin "start-${appConfig.domain}" ''
                        #!${pkgs.bash}/bin/bash
                        export PORT=${toString appConfig.port}
                        export RAILS_ENV=production
                        export DOMAIN=${appConfig.domain}

                        cd ${railsApp}
                        ${rubyEnv.env}/bin/bundle exec rails server -p ${toString appConfig.port}
                      '';
                    in
                    {
                      description = "Rails Application Service for ${appConfig.domain}";
                      wantedBy = [ "multi-user.target" ];
                      after = [ "network.target" ];

                      environment = {
                        PORT = toString appConfig.port;
                        RAILS_ENV = "production";
                        DOMAIN = appConfig.domain;
                        PATH = "${rubyEnv.env}/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin";
                      };

                      serviceConfig = {
                        Type = "simple";
                        User = "rails-${appConfig.domain}";
                        Group = "rails-${appConfig.domain}";
                        WorkingDirectory = "${railsApp}";
                        ExecStart = "${startScript}/bin/start-${appConfig.domain}";
                        Restart = "always";
                        RestartSec = "10";
                        StateDirectory = "rails-${appConfig.domain}";
                      };
                    };
                }
              ) cfg
            );

            # Users, groups, and Caddy configuration remain the same
            users.users = lib.mkMerge (
              lib.mapAttrsToList (
                name: appConfig:
                lib.mkIf appConfig.enable {
                  "rails-${appConfig.domain}" = {
                    isSystemUser = true;
                    group = "rails-${appConfig.domain}";
                    home = "/var/lib/rails-${appConfig.domain}";
                    createHome = true;
                  };
                }
              ) cfg
            );

            users.groups = lib.mkMerge (
              lib.mapAttrsToList (
                name: appConfig:
                lib.mkIf appConfig.enable {
                  "rails-${appConfig.domain}" = { };
                }
              ) cfg
            );

            services.caddy.virtualHosts = lib.mkMerge (
              lib.mapAttrsToList (
                name: appConfig:
                lib.mkIf (appConfig.enable && appConfig.useCaddy) {
                  ${appConfig.domain} = {
                    extraConfig = ''
                      root * ${fetchGitRepo appConfig.gitUrl appConfig.gitRef appConfig.sha256}/public
                      encode gzip
                      file_server /assets/*
                      reverse_proxy localhost:${toString appConfig.port} {
                        header_up Host {host}
                        header_up X-Real-IP {remote_host}
                        header_up X-Forwarded-For {remote_host}
                        header_up X-Forwarded-Proto {scheme}
                      }
                      tls {
                        on_demand
                      }
                    '';
                  };
                }
              ) cfg
            );
          };
        };
    };
}
