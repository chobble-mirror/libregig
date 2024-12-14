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
  serviceConfig = {
    User = serviceName;
    Group = serviceName;
    StandardOutput = "journal";
    StandardError = "journal";
  };
  setupScript = pkgs.writeShellScriptBin "libregig-setup" ''
    set -e
    set -x
    mkdir -p "/var/lib/${runtimeDir}"
    cp -r "${libregig}/." "/run/${runtimeDir}"
    cp -r "/var/lib/${runtimeDir}/." "/run/${runtimeDir}"
  '';
in
{
  users.users.${serviceName} = {
    isSystemUser = true;
    group = serviceName;
  };

  users.groups.${serviceName} = { };

  systemd.services.${serviceName} = {
    description = "libregig for ${name}";
    environment = defaultEnvironment // environmentConfig;
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "${serviceName}-setup.service" ];
    requires = [ "${serviceName}-setup.service" ];
    serviceConfig = serviceConfig // {
      Type = "forking";
      RuntimeDirectory = runtimeDir;
      StateDirectory = runtimeDir;
      WorkingDirectory = "/run/${runtimeDir}";
      ExecStart = "+${env}/bin/rails server -p ${toString port}";
    };
  };

  systemd.services."${serviceName}-setup" = {
    description = "setup for ${serviceName}";
    environment = defaultEnvironment // environmentConfig;
    after = [ "users.target" ];
    before = [ "${serviceName}.service" ];
    requiredBy = [ "${serviceName}.service" ];
    serviceConfig = serviceConfig // {
      Type = "oneshot";
      ExecStart = "+${setupScript}/bin/libregig-setup";
    };
  };

  systemd.services."${serviceName}-migrate" = {
    description = "database migrations for ${serviceName}";
    environment = defaultEnvironment // environmentConfig;
    after = [ "${serviceName}-setup.service" ];
    requires = [ "${serviceName}-setup.service" ];
    before = [ "${serviceName}.service" ];
    requiredBy = [ "${serviceName}.service" ];
    serviceConfig = serviceConfig // {
      Type = "oneshot";
      WorkingDirectory = "/run/${runtimeDir}";
      ExecStart = "+${env}/bin/rails db:migrate";
    };
  };
}
