### BASH COMPATIBLE (Gets sourced by .shared.sh)
function isDarwin() {
    [[ "$uname" == "Darwin" ]]
}
alias isD=isDarwin
function isLinux() {
    [[ "$uname" == "Linux" ]]
}
alias isL=isLinux
##
isI() {
    ! test -z "$FORCE_INTERACTIVE" || [[ -o interactive ]] #[[ $- == *i* ]]
}
##
function isOutTty() {
    [ -t 1 ]
    # -t fd True if file descriptor fd is open and refers to a terminal.
}
# alias istty=isOutTty
function istty() { # aliases are not fnswappable
    isOutTty "$@"
}
##
alias isExpensive='[[ -z "$NIGHT_NO_EXPENSIVE" ]]'
alias isNotExpensive='[[ -n "$NIGHT_NO_EXPENSIVE" ]]'
##
function isDbg() {
    test -n "$DEBUGME"
}
alias isdbg=isDbg
function isNotDbg() {
    ! isDbg
}
##
