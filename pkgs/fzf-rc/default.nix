{ pkgs ? import <nixpkgs> {} }:

let
  completion   = import ./completion.nix   { inherit pkgs; };
  key_bindings = import ./key-bindings.nix { inherit pkgs; };
  rc           = import ./bashrc.nix       { inherit pkgs; };
in derivation {
  inherit (pkgs) system;

  name = "fzf-rc";
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./build ];

  inherit (pkgs) coreutils fzf perl;
  inherit completion key_bindings rc;
}
