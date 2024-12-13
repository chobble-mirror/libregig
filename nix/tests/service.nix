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

    machine.succeed("ls -la /run/libregig-default >&2")
    machine.succeed("cd /run/libregig-default && cp env-example .env >&2")
    machine.succeed("cd /run/libregig-default && ${env}/bin/rails db:migrate >&2")
  '';
}
