{
  pkgs,
  env,
  ruby,
  self,
}:
let
  commonDeps = import ../dependencies.nix { inherit pkgs env ruby; };
  libregig = ../..;
in
pkgs.nixosTest {
  name = "service-test";

  nodes.machine =
    { lib, pkgs, ... }:
    {
      imports = [ self.nixosModules.default ];
      services.libregig.instances.default = {
        enable = true;
        port = 3000;
        environment = {
          RAILS_ENV = "test";
          FORCE_SSL = "false";
          ASSUME_SSL = "false";
        };
      };
      environment.systemPackages = commonDeps;
    };
  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("ls -la /var/lib/libregig-default >&2")
    machine.succeed("cp ${libregig}/env-example /var/lib/libregig-default/.env >&2")
    machine.succeed("systemctl start libregig-default-migrate >&2")
    machine.succeed("systemctl start libregig-default >&2 &")
    machine.wait_for_open_port(3000)
    response = machine.succeed("curl -I -s -o /dev/null -w '%{redirect_url}' http://127.0.0.1:3000")
    if "127.0.0.1:3000/login" not in response:
        raise Exception("could not load app")
  '';
}
