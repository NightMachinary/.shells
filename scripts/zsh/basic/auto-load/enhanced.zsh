re 'self-enh enh-mkdest' cp ln
_h_mv() {
    emd_c='command mv' enh-mkdest "$@"
}
mv () {
    local out
    args-nochromefile "$@"
    set -- "${out[@]}"
    if [ "$#" -ne 1 ] || [ ! -e "$1" ]; then
        _h_mv "$@"
    else
        local newfilename="$1"
        vared newfilename || {
            ecerr "$0: Canceled"
            return 1
        }
        # bash: read -ei "$1" newfilename
        _h_mv -v -- "$1" "$newfilename"
    fi
}
mv2 () {
    (( $#@ < 2 )) && { ecerr "Usage: mv2 <dest> <path> ..." ; return 1 }
    reval-ec mv "${@[-1]}" "${@[1,-2]}"
}
alias noglob='noglob ruu ""'
watchm() {
    ruu "watch -n $1" "${@:2}"
}
