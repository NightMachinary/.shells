function timer() {
    doc aliased to timer with noglob
    local t=$1 cmd=("${@[2,-1]}")
    test -z "$cmd[*]" && cmd=(eval lo_s=20 loop ot-play-happybirthday)
    sleep $(($t * 60)) && {
        terminal-notifier -title "Timer" -message ""
        reval "$cmd[@]"  #eval ${(q+@)@[2,-1]:-${(z)/#/loop ot-play-happybirthday}}
    }
}
noglobfn timer
