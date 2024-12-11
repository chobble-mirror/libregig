rm Gemfile.lock
rm gemset.nix
nix-shell -p ruby_3_2 --run "bundler lock"
nix run github:inscapist/bundix
