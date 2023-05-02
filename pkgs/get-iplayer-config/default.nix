{ nixpkgs ? import <nixpkgs> {}, system, dhall-lang, file-split }:

let
  src     = ./src;
in
  with nixpkgs;

derivation {
  inherit system;

  name      = "get-iplayer-config";
  builder   = "${bash}/bin/bash";
  src       =  src;
  args      =  [ ./builder.sh ];

  dhall_lang   = dhall-lang;
  fileSplit    = file-split;
  locales      = glibcLocales;
  inherit coreutils dhall file-split;

}
