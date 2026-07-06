{ pkgs }: ''# https://www.youtube.com/watch?v=1a5NiMhqAR0

# Extended-search mode (use +x or --no-extended to disable)
export FZF_DEFAULT_OPTS="--extended --reverse --preview '[[ -d {} ]] && ${pkgs.tree}/bin/tree -C {} || ${pkgs.bat}/bin/bat --style=numbers --color=always --line-range :500 {}'"

fzf_share=${pkgs.fzf}/bin/fzf-share

source @fn_completion@
source @fn_key_bindings@

# https://pragmaticpineapple.com/four-useful-fzf-tricks-for-your-terminal/
##_fzf_comprun() {
##  local cmd="$1"; shift
##
##  case "$cmd" in
##    cd ) ${pkgs.fzf}/bin/fzf "$@" --preview 'tree -C {} | head -200'                                  ;;
##    *  ) ${pkgs.fzf}/bin/fzf "$@" --preview 'bat --style=numbers --color=always --line-range :500 {}' ;;
##  esac
##}
''

# Local Variables:
# mode: sh
# End:
