{ pkgs, bash-header }: ''

source ${bash-header}

Cmd[lsmod]=${pkgs.kmod}/bin/lsmod
Cmd[kmonad]=${pkgs.kmonad}/bin/kmonad

# ------------------------------------------------------------------------------

Usage="$(''${Cmd[cat]} <<EOF
usage: $Progname FILENAME*

do some stuff

Standard Options:
  -v | --verbose  Be more garrulous, including showing external commands.
  --dry-run       Make no changes to the so-called real world.
  --debug         Output development/debugging messages.
  --help          This help.
EOF
)"

# ------------------------------------------------------------------------------

main() {
  local -a inputs
  capture_array inputs gocmdnodryrun 10 ls /dev/input/by-path/*-kbd

## input="$(echo /dev/input/by-path/*-kbd)"; lsmod | grep uinput && sudo kmonad -i "device-file \"$input\""  -f -l debug ~/nix/default/kmonad/null.kbd --output 'uinput-sink "input"

  case ''${#inputs[@]} in
    0 ) die 13 'no inputs found' ;;

    1 ) # we send to /dev/null rather than using, say --silent because that
        # causes grep to exit as soon as it sees a match, which then causes
        # lsmod to get a sigPIPE which we see as an error.
        #
        # we could catch the sigPIPE, but that would then shadow other, more
        # serious sigPIPEs
        if ! gocmdnodryrun 11 lsmod | gocmd01nodryrun 12 grep uinput >/dev/null
        then
          die 16 "no uinput module found in lsmod"
        fi
        local input="''${inputs[0]}"
        local -a args=( --input 'device-file "'"$input"'"'
                        --output 'uinput-sink "input"'
                        --log-level debug
                        --fallthrough ~/nix/default/kmonad/null.kbd
                      )
        gocmd 14 sudo ''${Cmd[kmonad]} "''${args[@]}"
        ;;

    * ) die 15 "too many inputs found: »''${inputs[*]}«" ;;
  esac
}

# ------------------------------------------------------------------------------

orig_args="$@"
getopt_opts=( -o v --long verbose,dry-run,debug,help )
OPTS=$( ''${Cmd[getopt]} "''${getopt_opts[@]}" -n "$Progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

args=()
action=toggle
while true; do
  case "$1" in
    # !!! don't forget to update usage !!!
    -v | --verbose  ) Verbose=$((Verbose+1)) ; shift   ;;
    --help          ) usage                            ;;
    --dry-run       ) DryRun=true            ; shift   ;;
    --debug         ) Debug=true             ; shift   ;;
    --              ) shift; args+=( "$@" )  ; break   ;;
    *               ) args+=( "$1" )         ; shift   ;;
  esac
done

case "''${#args[@]}" in
  0 ) main /etc/passwd    ;;
  * ) main "''${args[@]}" ;;
esac

# -- that's all, folks! --------------------------------------------------------

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# fill-column: 80
# End:
''
