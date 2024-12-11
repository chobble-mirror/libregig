{
  pkgs,
  env,
  ruby,
}:
let
  commonDeps = import ../dependencies.nix { inherit pkgs env ruby; };
  gemdir = pkgs.runCommand "rack-gemdir" { } ''
    mkdir -p $out
    cp ${./rack-service/Gemfile} $out/Gemfile
    cp ${./rack-service/Gemfile.lock} $out/Gemfile.lock
    cp ${./rack-service/gemset.nix} $out/gemset.nix
  '';

  rubyWithRack = pkgs.bundlerEnv {
    name = "ruby-with-rack";
    ruby = pkgs.ruby;
    gemdir = gemdir;
    exes = [ "rackup" ];
  };

  rackConfig = pkgs.writeText "config.ru" ''
    require 'rack'

    app = lambda do |env|
      [200, {'content-type' => 'text/html'}, ['Welcome']]
    end

    run app
  '';
in
pkgs.nixosTest {
  name = "rack-service-test";
  nodes.machine =
    { lib, pkgs, ... }:
    let
      rackService = import ../modules/rack-service.nix {
        inherit
          lib
          pkgs
          rubyWithRack
          rackConfig
          ;
      };
    in
    {
      imports = [ rackService ];
      environment.systemPackages = commonDeps ++ [ rubyWithRack ];
    };

  testScript = ''
    machine.start()
    machine.wait_for_unit("network.target")
    machine.succeed("ls -l ${rubyWithRack}/bin/rackup")
    machine.succeed("journalctl -u rack-server --no-pager >&2")
    machine.wait_for_unit("rack-server")
    machine.wait_for_open_port(3000)
    response = machine.succeed("curl -s http://localhost:3000/")
    if "Welcome" not in response:
        raise Exception("Expected welcome page not found")
  '';
}
