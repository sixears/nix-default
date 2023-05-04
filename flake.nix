{
  description = "basic setup for nix";

  inputs = {
    nixpkgs.url     = github:nixos/nixpkgs/be44bf67; # nixos-22.05 2022-10-15
    flake-utils.url = github:numtide/flake-utils/c0e246b9;
    hpkgs1.url      = github:sixears/hpkgs1/r0.0.9.0;
    myPkgs          = {
      url    = github:sixears/nix-pkgs/r0.0.1.0;
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
  };

  outputs = { self, nixpkgs, flake-utils, hpkgs1, myPkgs }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system:
      let
        pkgs    = nixpkgs.legacyPackages.${system};
        hpkgs   = hpkgs1.packages.${system};
        my-pkgs = myPkgs.packages.${system};

        # -- vpn -----------------------

        pia-openvpn = import ./pkgs/pia-openvpn { inherit pkgs; };

        # -- get-iplayer ---------------

        dhall-lang = import ./pkgs/dhall-lang { nixpkgs = pkgs; };
        get-iplayer-config =
          import ./pkgs/get-iplayer-config { nixpkgs = pkgs;
                                             inherit system dhall-lang;
                                             file-split = hpkgs.file-split;
                                           };

      in
        rec {
          packages = flake-utils.lib.flattenTree (with pkgs; {
            # general utilities
            inherit miscfiles nfs-utils wget direnv nix-direnv;

            inherit footswitch;

            # get-iplayer
            inherit get-iplayer-config;

            # console tools & editors
            inherit screen tmux; tmux-man = pkgs.tmux.man;
            emacs = emacsPackagesNg.emacsWithPackages (ps: with ps; [
                babel
                flycheck
                flycheck-haskell
                haskell-mode
                haskell-unicode-input-method
                ivy
                markdown-mode
                mmm-mode
                nix-mode
                org-babel-eval-in-repl
                swiper
                yaml-mode
                yasnippet

                tuareg # an ocaml mode

                # used for liquid mode
                popup button-lock pos-tip flycheck-color-mode-line
                # flycheck-liquidhs.el

                pkgs.git

                pkgs.haskellPackages.stylish-haskell
                pkgs.haskellPackages.hlint
                pkgs.haskellPackages.ghc
              ]);

            # email
            inherit mutt;

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

            inherit jq;
            inherit unar unzip;
            inherit mkvtoolnix;
            inherit usbutils; # lsusb
            inherit graph-easy;
            inherit keepass;
            # not currently used
            #  inherit vulnix;

            inherit scowl; # for dict/words
            inherit (my-pkgs) byobu;
          });
        }
    );
}
