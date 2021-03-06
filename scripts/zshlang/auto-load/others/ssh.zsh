ashL() {
    local a=() i
    for i in "$@[2,-1]"
    do
        a+=(-L "${i}:localhost:${i}")
    done
    ash -NT "$1" "$a[@]"
}
##
function kitty-terminfo-install() {
    infocmp -x xterm-kitty | ssh "$@" tic -x -o \~/.terminfo/ /dev/stdin
}
function ssh() {
  if fn-isTop && isKitty ; then
    # will install the xterm-kitty terminal definition on the remote in your home directory.
    # Only needs to run once per host
    kitty +kitten ssh "$@"
  else
    command ssh "$@"
  fi
}
##
function firewall-allow-mosh-darwin() {
  # https://github.com/mobile-shell/mosh/issues/898

  local fw='/usr/libexec/ApplicationFirewall/socketfilterfw'
  local mosh_sym="${commands[mosh-server]}"
  local mosh_abs
  mosh_abs="$(greadlink -f "$mosh_sym")" @TRET

  reval-ec sudo "$fw" --setglobalstate off

  reval-ec sudo "$fw" --remove "$mosh_sym"
  reval-ec sudo "$fw" --remove "$mosh_abs"

  reval-ec sudo "$fw" --add "$mosh_sym"
  reval-ec sudo "$fw" --unblockapp "$mosh_sym"

  reval-ec sudo "$fw" --add "$mosh_abs"
  reval-ec sudo "$fw" --unblockapp "$mosh_abs"

  reval-ec sudo "$fw" --setglobalstate on
}
##
