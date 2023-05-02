{ pkgs, pia-openvpn }: pkgs.writers.writeBashBin "pia" ''
set -eu -o pipefail

echo "see https://helpdesk.privateinternetaccess.com/hc/en-us/articles/219438247-Installing-OpenVPN-PIA-on-Linux"

if [ $# -ne 1 ]; then
    echo "usage: $0 <proxy location>" 1>&2; exit 2
fi

location="$1"
ovpn="${pia-openvpn}/share/$location.ovpn"

if [ \! -e "$ovpn" ]; then
    echo "no such proxy location config: $ovpn" 1>&2; exit 2
fi

cd ${pia-openvpn}/share
/run/wrappers/bin/sudo ${pkgs.openvpn}/bin/openvpn "$ovpn"
''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:
