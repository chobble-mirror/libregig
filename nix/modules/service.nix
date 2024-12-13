{
  lib,
  pkgs,
  env,
  ruby,
  libregig,
  port ? 3000,
  environmentConfig ? { },
  ...
}:

let
  defaultEnvironment = {
    GEM_HOME = "${env}";
    PATH = lib.mkForce "${env}/bin:${ruby}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin";
    RAILS_ENV = "production";
    RAILS_LOG_TO_STDOUT = "1";
    RAILS_SERVE_STATIC_FILES = "1";
    SECRET_KEY_BASE = "secret_key_base";
  };
in
{
  systemd.services.libregig = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    environment = defaultEnvironment // environmentConfig;
    serviceConfig = {
      RuntimeDirectory = "libregig";
      WorkingDirectory = "/run/libregig";
      ExecStartPre = "+${pkgs.coreutils}/bin/cp -r ${libregig}/. /run/libregig/";
      ExecStart = "${env}/bin/rails server -p ${toString port}";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
}
