{
  description = "basic setup for nix";

  inputs = {
    nixpkgs.url     = github:NixOS/nixpkgs/667d5cf1; # nixos-26.05 2026-06-26
    flake-utils.url = github:numtide/flake-utils/c0e246b9;
    hpkgs1.url      = github:sixears/hpkgs1/r0.0.55.0;
    myPkgs          = {
      url    = github:sixears/nix-pkgs/r0.0.16.0;
#      url    = path:/home/martyn/nix/pkgs;
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
    bashHeader      = {
      url    = github:sixears/bash-header/r0.0.7.0;
#      url    = path:/home/martyn/src/bash-header;
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
  };

  outputs = { self, nixpkgs, flake-utils, hpkgs1, myPkgs, bashHeader }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system:
      let
        pkgs        = nixpkgs.legacyPackages.${system};
        hpkgs       = hpkgs1.packages.${system};
        my-pkgs     = myPkgs.packages.${system};
        bash-header = bashHeader.packages.${system}.bash-header;

        # -- vpn -----------------------

        pia-openvpn = import ./pkgs/pia-openvpn { inherit pkgs; };

        # -- get-iplayer ---------------

        dhall-lang = import ./pkgs/dhall-lang { nixpkgs = pkgs; };
        get-iplayer-config =
          import ./pkgs/get-iplayer-config { nixpkgs = pkgs;
                                             inherit system dhall-lang;
                                             file-split = hpkgs.file-split;
                                           };

        # -- brian ---------------------

        brian = hpkgs.brian;

      in
        rec {
          packages = flake-utils.lib.flattenTree (with pkgs; {
            # general utilities
            inherit miscfiles nfs-utils wget ncdu;
            # direnv showed strange behaviours that I couldn't track down, such
            # sourcing my regular .bash_login in a way that would cause
            # 'builtin: complete: not a shell builtin' when logging in over ssh
            # but not normally; I could find no way to explain or reproduce
            # this.  And the way it inserted itself into the shell prompt was
            # also a pain, and didn't play well with, e.g., preexec.
            # Suggest that, if I need a direnv-like thing; roll my own.
            ## direnv nix-direnv

            inherit footswitch;

            # get-iplayer
            inherit get-iplayer-config;

            # console tools & editors
            inherit (my-pkgs) tmux tmux-man;
            inherit screen;

            # email
            inherit mutt gnupg pinentry-curses lynx;

            # -- haskell tools ---------

            # nabal uses cabal, cabal needs ar (but daesn't depend upon it, ugh)
            inherit hlint binutils cabal2nix;
            ## nabal = import ../../pkgs/nabal { inherit nixpkgs; };
            #  liquidhaskell
            #  inherit z3;
            #  liquidhaskell = haskellPackages.liquidhaskell;

            # -- shell tools -----------

            inherit shellcheck;

            # -- vpn -------------------

            pia = import ./pkgs/pia.nix { inherit pkgs pia-openvpn; };

            # -- nix tools -------------
            inherit nix-prefetch-git nix-prefetch-github;

            # -- miscellaneous ---------

            inherit jq pv yq;
            inherit unar unzip;
            inherit mkvtoolnix;
            inherit usbutils; # lsusb
            inherit graph-easy;
            inherit keepass;
            # not currently used
            #  inherit vulnix;
            inherit moreutils;
            inherit scowl; # for dict/words
            # inherit (my-pkgs) byobu;

            # -- kmonad ----------------

            kmonad-null =
              let null-cfg = ./kmonad/null.kbd;
                  src = import ./kmonad/kmonad-null.nix
                               { inherit pkgs bash-header null-cfg; };
              in  pkgs.writers.writeBashBin "kmonad-null" src;

            # -- brian -----------------

            inherit brian;

            # -- fzf-rc -----------------------

            fzf-rc = import ./pkgs/fzf-rc { inherit pkgs; };
          });
        }
    );
}
