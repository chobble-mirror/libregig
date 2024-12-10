{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    bundix
    libyaml
    nodejs_22
    pkg-config
    ruby_3_2
    rubyPackages_3_2.concurrent-ruby
    rubyPackages_3_2.htmlbeautifier
    rubyPackages_3_2.psych
    rubyPackages_3_2.rails
    rubyPackages_3_2.rugged
    rubyPackages_3_2.sassc
    rubyPackages.execjs
    sqlite
    xclip
  ];
}
