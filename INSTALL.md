# Libregig - development environment installation instructions

## Option: `nix` in single-user mode on a Linux system

### Install
1. Ensure `git` is installed on your system.

1. `cd` to the desired parent directory for the `libregig` development environment.

1. Clone the `libregig` repo:

        git clone https://git.chobble.com/chobble/libregig.git

1. Install `nix` in single-user mode (this will likely require `sudo` permissions):

        sh <(curl -L https://nixos.org/nix/install) --no-daemon

1. Log out and log in again to bring in the `.profile` shell environment settings.

1. Add to `${HOME}/.config/nix/nix.conf` (creating the subdirectory and file as necessary):

        experimental-features = nix-command flakes

1. `cd` to the `libregig` repo directory.

1. Enter the `nix` development environment (the first run will build all the project dependencies and take some time):

        nix develop

1. Set up the server environment:

        cp env-example .env

2. Populate some test data and initialize the database:

        rails db:seed
        rails db:migrate

3. Run the `rails` server:

        rails server

### Uninstall
1. Remove the local repo:

        rm -r libregig

2. Remove ̀nix` single-user mode install and artifacts:

        sudo rm -rf /nix ~/.nix-channels ~/.nix-defexpr ~/.nix-profile

3. (optional) Remove the `nix`-related line in `${HOME}/.profile`.

4. (optional) Remove the `nix` config:

        rm -r ${HOME}/.config/nix/

## References
* [single-user nix installation instructions](https://nix.dev/manual/nix/2.24/installation/installing-binary#single-user-installation) (v 2.24)
* [single-user nix uninstall instructions](https://nix.dev/manual/nix/2.24/installation/uninstall#single-user) (v 2.24)
