{ pkgs      ? import <nixpkgs> {}
, stdenv    ? pkgs.stdenv
, fetchurl  ? pkgs.fetchurl
, coreutils ? pkgs.coreutils
, unzip     ? pkgs.unzip
, zlib      ? pkgs.zlib
}:

let
  url    = "https://www.privateinternetaccess.com/openvpn/openvpn-strong-tcp.zip";
  # sha256 = "0gzh5pwqd3ypjhip33chn72v2d5mydgrqzg4m4sgvcx7mvb99sgx";
  # found with nix-prefetch-url https://www.privateinternetaccess.com/openvpn/openvpn-strong-tcp.zip
  sha256 = "0r32jhrx2xkq9bs1bc1pzmi02jp5jci3ry8qzwlw8mxjyvkncwza";

in stdenv.mkDerivation rec {
  name = "pia-openvpn";

  src = fetchurl { inherit url sha256; };
  unpackPhase = '' mkdir -v "$out"
                  "${unzip}/bin/unzip" -d "$out/share" "${src}"
                '';
  dontBuild = true;
  installPhase = "${coreutils}/bin/true";
}
