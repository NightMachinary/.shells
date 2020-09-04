### BASH COMPATIBLE (Gets sourced by .shared.sh)
function isDarwin() {
    [[ "$uname" == "Darwin" ]]
}
alias isD=isDarwin
function isLinux() {
    [[ "$uname" == "Linux" ]]
}
alias isL=isLinux
isI() {
    ! test -z "$FORCE_INTERACTIVE" || [[ -o interactive ]] #[[ $- == *i* ]]
}
alias isExpensive='[[ -z "$NIGHT_NO_EXPENSIVE" ]]'
alias isNotExpensive='[[ -n "$NIGHT_NO_EXPENSIVE" ]]'
function isDbg() {
    test -n "$DEBUGME"
}
alias isdbg=isDbg
function isNotDbg() {
    ! isDbg
}

