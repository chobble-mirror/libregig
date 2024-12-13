{
  lib,
  pkgs,
  env,
  ruby,
  libregig,
  name ? "default",
  port ? 3000,
  environmentConfig ? { },
  ...
}:

let
  serviceName = "libregig-${name}";
  runtimeDir = "libregig-${name}";
  defaultEnvironment = {
    GEM_HOME = "${env}";
    RAILS_ENV = "production";
    RAILS_LOG_TO_STDOUT = "1";
    RAILS_SERVE_STATIC_FILES = "1";
    SECRET_KEY_BASE = "secret_key_base";
  };
  setupScript = pkgs.writeShellScriptBin "${serviceName}-setup" ''
    set -e
    set -x
    mkdir -p "/var/lib/${runtimeDir}"
    chmod 0664 -R "/var/lib/${runtimeDir}"
    cp -r "${libregig}/." "/run/${runtimeDir}"
    cp -r "/var/lib/${runtimeDir}/." "/run/${runtimeDir}"
    chmod 0664 -R /run/${runtimeDir}
  '';
  migrateScript = pkgs.writeShellScriptBin "${serviceName}-migrate" ''
    set -e
    set -x
    cd /run/${runtimeDir}
    ${env}/bin/rails db:migrate
  '';
in
{
  users.users.${serviceName} = {
    isSystemUser = true;
    group = serviceName;
  };

  users.groups.${serviceName} = { };

  systemd.services.${serviceName} = {
    enable = true;
    # wantedBy = [ "multi-user.target" ];
    after = [ "${serviceName}-setup.service" ];
    requires = [ "${serviceName}-setup.service" ];
    environment = defaultEnvironment // environmentConfig;
    serviceConfig = {
      User = serviceName;
      Group = serviceName;
      Type = "forking";
      RuntimeDirectory = runtimeDir;
      StateDirectory = runtimeDir;
      WorkingDirectory = "/run/${runtimeDir}";
      ExecStart = "+${env}/bin/rails server -p ${toString port}";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  systemd.services."${serviceName}-setup" = {
    description = "Setup for ${serviceName}";
    before = [ "${serviceName}.service" ];
    requiredBy = [ "${serviceName}.service" ];
    serviceConfig = {
      User = serviceName;
      Group = serviceName;
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "+${setupScript}/bin/libregig-default-setup";
    };
  };

  systemd.services."${serviceName}-migrate" = {
    description = "Run database migrations for ${serviceName}";
    environment = defaultEnvironment // environmentConfig;
    serviceConfig = {
      User = serviceName;
      Group = serviceName;
      Type = "oneshot";
      WorkingDirectory = "/run/${runtimeDir}";
      ExecStart = "+${migrateScript}/bin/libregig-default-migrate";
    };
    after = [ "${serviceName}-setup.service" ];
    requires = [ "${serviceName}-setup.service" ];
    before = [ "${serviceName}.service" ];
    requiredBy = [ "${serviceName}.service" ];
  };
}
