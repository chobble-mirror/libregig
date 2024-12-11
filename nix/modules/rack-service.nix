{
  lib,
  pkgs,
  rubyWithRack,
  rackConfig,
  ...
}:
{
  systemd.services.rack-server = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    environment = {
      GEM_HOME = "${rubyWithRack}";
      PATH = lib.mkForce "${rubyWithRack}/bin:${pkgs.ruby}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin";
    };
    serviceConfig = {
      RuntimeDirectory = "rack-server";
      WorkingDirectory = "/run/rack-server";
      ExecStart = "${rubyWithRack}/bin/rackup -o 0.0.0.0 -p 3000";
    };
    preStart = ''
      cp ${rackConfig} /run/rack-server/config.ru
    '';
  };
}
