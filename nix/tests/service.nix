{
  pkgs,
  env,
  ruby,
}:
let
  commonDeps = import ../dependencies.nix { inherit pkgs env ruby; };
  railsApp = ../..;
in
pkgs.nixosTest {
  name = "rails-service-test";
  nodes.machine =
    { lib, pkgs, ... }:
    let
      railsService = import ../modules/service.nix {
        inherit
          lib
          pkgs
          env
          ruby
          railsApp
          ;
        environmentConfig = {
          RAIL_USE_SSL = "false";
          RAILS_ASSUME_SSL = "false";
        };
      };
    in
    {
      imports = [ railsService ];
      environment.systemPackages = commonDeps;
    };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    machine.succeed("ls -la /run/rails-server >&2")
    machine.succeed("cd /run/rails-server && cp env-example .env >&2")
    machine.succeed("cd /run/rails-server && ${env}/bin/rails db:migrate >&2")

    machine.succeed("systemctl start rails-server >&2 &")
    machine.execute("journalctl -u rails-server >&2")
    machine.wait_for_unit("rails-server", timeout = 5)
    machine.succeed("journalctl -u rails-server --no-pager >&2")

    machine.succeed("curl -I -s http://127.0.0.1:3000 >&2")

    response = machine.succeed("curl -I -s -o /dev/null -w '%{redirect_url}' http://127.0.0.1:3000")
    machine.succeed(f"echo 'Response was: {response}' >&2")

    if "/login" not in response:
        machine.succeed("journalctl -u rails-server --since '1m ago' --no-pager >&2")
        raise Exception("could not load app")
  '';
}
