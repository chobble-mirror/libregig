{
  pkgs,
  env,
  ruby,
}:
let
  commonDeps = import ../dependencies.nix { inherit pkgs env ruby; };
  libregig = ../..;
in
pkgs.nixosTest {
  name = "service-test";
  nodes.machine =
    { lib, pkgs, ... }:
    let
      service = import ../modules/service.nix {
        inherit
          lib
          pkgs
          env
          ruby
          libregig
          ;
        name = "default";
        environmentConfig = {
          RAILS_ENV = "test";
          FORCE_SSL = "false";
          ASSUME_SSL = "false";
        };
      };
    in
    {
      imports = [ service ];
      environment.systemPackages = commonDeps;
    };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("cp ${libregig}/env-example /var/lib/libregig-default/.env >&2")
    machine.succeed("systemctl start libregig-default-migrate >&2")
    machine.succeed("systemctl start libregig-default >&2 &")
    machine.wait_for_open_port(3000)
    response = machine.succeed("curl -I -s -o /dev/null -w '%{redirect_url}' http://127.0.0.1:3000")
    if "127.0.0.1:3000/login" not in response:
        raise Exception("could not load app")
  '';
}
