{
  pkgs,
  env,
  ruby,
}:
let
  commonDeps = import ../dependencies.nix { inherit pkgs env ruby; };

  gemfile = pkgs.writeText "Gemfile" ''
    source 'https://rubygems.org'
    gem 'rack'
    gem 'rackup'
    gem 'webrick'
  '';

  gemfileLock = pkgs.writeText "Gemfile.lock" ''
    GEM
      remote: https://rubygems.org/
      specs:
        rack (3.1.8)
        rackup (2.2.1)
          rack (>= 3)
        webrick (1.9.1)

    PLATFORMS
      ruby
      x86_64-linux

    DEPENDENCIES
      rack
      rackup
      webrick

    BUNDLED WITH
       2.5.22
  '';

  gemsetNix = pkgs.writeText "gemset.nix" ''
    {
      rack = {
        groups = ["default"];
        platforms = [];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1cd13019gnnh2c0a3kj27ij5ibk72v0bmpypqv4l6ayw8g5cpyyk";
          target = "ruby";
          type = "gem";
        };
        targets = [];
        version = "3.1.8";
      };
      rackup = {
        dependencies = ["rack"];
        groups = ["default"];
        platforms = [];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "13brkq5xkj6lcdxj3f0k7v28hgrqhqxjlhd4y2vlicy5slgijdzp";
          target = "ruby";
          type = "gem";
        };
        targets = [];
        version = "2.2.1";
      };
      webrick = {
        groups = ["default"];
        platforms = [];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "12d9n8hll67j737ym2zw4v23cn4vxyfkb6vyv1rzpwv6y6a3qbdl";
          target = "ruby";
          type = "gem";
        };
        targets = [];
        version = "1.9.1";
      };
    }    
  '';

  # Create a temporary gemdir structure
  gemdir = pkgs.runCommand "rack-gemdir" { } ''
    mkdir -p $out
    cp ${gemfile} $out/Gemfile
    cp ${gemfileLock} $out/Gemfile.lock
    cp ${gemsetNix} $out/gemset.nix
  '';

  # Create rubyWithRack using the gemdir
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
  name = "basic-rails-test";

  nodes.machine =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = commonDeps ++ [ rubyWithRack ];
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
