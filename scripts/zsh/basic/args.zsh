function in-or-args2() {
    (( $# )) && inargs=( "$@" ) || inargs="${$(</dev/stdin ; ec .)%.}"
    # https://unix.stackexchange.com/questions/206449/elegant-way-to-prevent-command-substitution-from-removing-trailing-newline
}
function in-or-args() {
    (( $# )) && ec "$@" || ec "${$(</dev/stdin ; ec .)%.}"
}
function arr0() { ec "${(pj.\0.)@}" }
function arrN() { ec "${(pj.\n.)@}" }
function in-or-args-arr0() {
    (( $# )) && arr0 "$@" || ec "$(</dev/stdin)"
}
function in-or-args-arrN() {
    (( $# )) && arrN "$@" || ec "$(</dev/stdin)"
}
