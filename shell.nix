{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.nodejs_22
    pkgs.ruby_3_3
    pkgs.rubyPackages_3_3.concurrent-ruby
    pkgs.rubyPackages_3_3.htmlbeautifier
    pkgs.rubyPackages_3_3.rails
    pkgs.rubyPackages_3_3.rugged
    pkgs.rubyPackages_3_3.sassc
    pkgs.rubyPackages.execjs
    pkgs.sqlite
    pkgs.xclip
  ];
  shellHook = ''
    git pull
  '';
}
