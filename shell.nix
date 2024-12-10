{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    bundix
    git
    nodejs_22
    ruby_3_3
    rubyPackages_3_3.concurrent-ruby
    rubyPackages_3_3.htmlbeautifier
    rubyPackages_3_3.rails
    rubyPackages_3_3.rugged
    rubyPackages_3_3.sassc
    rubyPackages.execjs
    sqlite
    xclip
  ];
}
