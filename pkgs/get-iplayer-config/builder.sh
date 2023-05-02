set -eu -o pipefail

file_split=${fileSplit}/bin/file-split

export LANG=en_GB.UTF-8
export LOCALE_ARCHIVE=${locales}/lib/locale/locale-archive

share=$out/share/get-iplayer-config
$coreutils/bin/mkdir -p $share
$coreutils/bin/cp --recursive --verbose $src/ src/
$coreutils/bin/chmod u+w src/
$coreutils/bin/rm -f src/prelude
$coreutils/bin/cp --verbose $dhall_lang/share/dhall-lang/prelude src/prelude
configs=~+/src/configs
config=~+/src/config
cd $share
$dhall/bin/dhall --explain text <<< "$configs $config" | $file_split -v -m -- '---- ' --------
