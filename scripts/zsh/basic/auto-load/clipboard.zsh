teec() {
    doc "teec; ec-and-copy; tee-copy;
Prints and copies its stdin.
See also: 'etee'." #MAGIC
    local out="$(</dev/stdin)"
    <<<"$out" pbcopy
    ec "$out"
}
aliasfn tee-copy teec
etee() {
    mdoc 'etee; Short for `eteec`. An enhancer that copies stdout and prints it, too.
See also: teec' MAGIC
    local out="$(eval "$(gquote "$@")")"
    <<<"$out" pbcopy
    ec "$out"
}
aliasfn reval-copy etee
function eccopy() {
    local out="$*"
    <<<"$out" pbcopy
    ec "$out"
}
function pbcopy() {
    local in="$(in-or-args "$@")"
    { false && (( $+commands[copyq] )) } && {
        silent copyq copy -- "$in"
    } || {
        (( $+commands[pbcopy] )) && {
            print -nr -- "$in" | command pbcopy
        }
    }
}
function pbpaste() {
    # local in="$(in-or-args "$@")"
    { false && (( $+commands[copyq] )) } && {
        copyq clipboard
    } || {
        (( $+commands[pbpaste] )) && command pbpaste
    }
}
