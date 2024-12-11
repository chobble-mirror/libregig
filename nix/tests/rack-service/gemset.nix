{
  rack = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cd13019gnnh2c0a3kj27ij5ibk72v0bmpypqv4l6ayw8g5cpyyk";
      target = "ruby";
      type = "gem";
    };
    targets = [ ];
    version = "3.1.8";
  };
  rackup = {
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13brkq5xkj6lcdxj3f0k7v28hgrqhqxjlhd4y2vlicy5slgijdzp";
      target = "ruby";
      type = "gem";
    };
    targets = [ ];
    version = "2.2.1";
  };
  webrick = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12d9n8hll67j737ym2zw4v23cn4vxyfkb6vyv1rzpwv6y6a3qbdl";
      target = "ruby";
      type = "gem";
    };
    targets = [ ];
    version = "1.9.1";
  };
}
