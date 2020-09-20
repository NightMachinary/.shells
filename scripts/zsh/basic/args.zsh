###
function in-or-args2() {
    (( $# )) && inargs=( "$@" ) || inargs="${$(</dev/stdin ; print -n .)[1,-2]}"
}
function in-or-args() {
    (( $# )) && ec "$@" || print -nr -- "${$(</dev/stdin ; print -n .)[1,-2]}"
}
function catp() {
    gtimeout 0.001s cat
}
##
function arr0() { print -nr -- "${(pj.\0.)@}" }
function arrN() { print -nr -- "${(pj.\n.)@}" }
# function in-or-args-arr0() {
#     (( $# )) && arr0 "$@" || ec "$(</dev/stdin)"
# }
# function in-or-args-arrN() {
#     (( $# )) && arrN "$@" || ec "$(</dev/stdin)"
# }
###
function args-nochromefile() {
    doc 'Converts file:/// to /. Outputs in $out'
    local arg
    out=()
    for arg in "$@"
    do
        [[ "$arg" =~ '^file://(/.*)$' ]] && out+="$match[1]" || out+="$arg"
    done
}
function rpargs() {
    doc 'Converts all existent paths in args to their abs path. Outputs both in NUL-delimited stdout and $out.'

    local i args
    args=()
    for i in "$@"
    do
        test -e "$i" && args+="$(realpath --canonicalize-existing -- "$i")" || args+="$i"
    done
    out=( "${args[@]}" )
    re "printf '%s\0'" "$args[@]"
}
function opts-urls() {
    doc "Partitions the arguments into (global variables) |urls| and |opts| (everything else)."
    
    opts=()
    urls=()
    local i
    for i in "$@" ; do
        if match-url2 "$i" ; then
            urls+="$i"
        else
            opts+="$i"
        fi
    done
}
