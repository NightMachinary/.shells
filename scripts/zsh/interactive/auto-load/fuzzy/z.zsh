ffz_last_query=''
function ffz() {
    ##
    # @retiredtodo2 We can bypass the interactive selection if the score of the top match is high enough compared to the second-best match, and have a `zi` that disables this auto-bypass.
    # DONE: We can also just cache the result for each query!
    ##
    setopt localoptions pipefail
    local query="${*:-$ffz_last_query}" sel
    ffz_last_query="$query"
    ##
    local fz_opts=( $fz_opts[@] --prompt "Z> ")
    ##
    # memoi-eval doesn't read from pipe
    sel="$( { serr zoxide query --list || true } | memoi_skiperr=y memoi_inheriterr=y memoi_od=0 memoi_expire=0 memoi-eval fzp "$query" | head -1)" ||  {
        return 1
    }
    if test -z "$deusvult" && ! test -e "$sel" ; then
        deus reval "$0" "$@"
        return $?
    fi
    cd "$sel"
}
aliasfn z ffz
aliasfn zi deus ffz
