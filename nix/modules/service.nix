{
  lib,
  pkgs,
  env,
  ruby,
  railsApp,
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
  systemd.services.rails-server = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    environment = defaultEnvironment // environmentConfig;
    serviceConfig = {
      RuntimeDirectory = "rails-server";
      WorkingDirectory = "/run/rails-server";
      ExecStartPre = "+${pkgs.coreutils}/bin/cp -r ${railsApp}/. /run/rails-server/";
      ExecStart = "${env}/bin/rails server -p 3000";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
}
