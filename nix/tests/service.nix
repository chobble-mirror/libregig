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

    machine.succeed("ls -la /run/libregig >&2")
    machine.succeed("cd /run/libregig && cp env-example .env >&2")
    machine.succeed("cd /run/libregig && ${env}/bin/rails db:migrate >&2")

    machine.succeed("systemctl start libregig >&2 &")
    machine.execute("journalctl -u libregig >&2")
    machine.wait_for_unit("libregig", timeout = 5)
    machine.succeed("journalctl -u libregig --no-pager >&2")

    machine.succeed("curl -I -s http://127.0.0.1:3000 >&2")

    response = machine.succeed("curl -I -s -o /dev/null -w '%{redirect_url}' http://127.0.0.1:3000")
    if "127.0.0.1:3000/login" not in response:
        raise Exception("could not load app")
  '';
}
