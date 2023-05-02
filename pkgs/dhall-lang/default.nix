{ nixpkgs ? import <nixpkgs> {} }:

with nixpkgs;
derivation {
  inherit system;
  name = "dhall-lang";

  src = fetchFromGitHub {
    owner = "dhall-lang";
    repo = "dhall-lang";
#    rev = "v13.0.0";
#    sha256 = "0kg3rzag3irlcldck63rjspls614bc2sbs3zq44h0pzcz9v7z5h9";
    rev = "v20.2.0";
    sha256 = "0wqcj5w4x24j3p73qrc5x5gci2mxkvli3kphg53qwis4b8g703zp";
  };

  installPhase = ''
    echo "OUT: $out"
    mkdir -p $out
    ls -l
  '';

  inherit coreutils;
  builder = "${bash}/bin/bash";
  args    = [ ./builder.sh ];
}
