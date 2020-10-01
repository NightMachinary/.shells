### Vars
##
FZF_SIMPLE_PREVIEW='printf -- "%s " {}'
# fzf supports wrapping itself. # | command fold -s -w $FZF_PREVIEW_COLUMNS'
# << was bad for dash, no <<< in dash
##
### Functions
function fz-empty() {
    fz_empty='y' fz "$@"
}
function fz() {
    # "Use `fnswap fzf-gateway gq fz` to get the final command for use in other envs
    local opts emptyMode="${fz_empty}"
    opts=(${(@)fz_opts} --exit-0) #Don't quote it or it'll insert empty args
    # --exit-0 : By using this we'll lose the automatic streaming feature of fzf as we need to wait for the whole input. (Update: It doesn't seem that the streaming feature is useful at all, as it doesn't show anything until completion in my tests ...)
    # --select-1 : auto-selects if only one match
    test -n "$fz_no_preview" || opts+=(--preview "$FZF_SIMPLE_PREVIEW" --preview-window down:7:wrap:hidden)

    local cmdbody=( "${(@)opts}" "$@" )
    if test -z "$emptyMode" ; then
        fzf-noempty "$cmdbody[@]" # moved options to FZF_DEFAULT_OPTS
    else
        fzf-gateway "$cmdbody[@]"
    fi
}
function fzf-noempty() {
    local in="$(</dev/stdin)" # So we need to wait for the whole input to finish first.
    test -z "$in" && { return 130 } || { ec "$in" | fzf-gateway "$@" }
}
function fzf-gateway() {
    SHELL="${FZF_SHELL:-${commands[dash]}}" fzf-tmux -p90% "$@" | sponge
    # sponge is necessary: https://github.com/junegunn/fzf/pull/1946#issuecomment-687714849
}
function fzp() {
    local opts=("${@[1,-2]}") query="${@[-1]}"

    # FNSWAP: isI
    if isI ; then
        fz "$opts[@]" --query "$query"
    else
        fz --no-sort "$opts[@]" --filter "$query"
    fi
}
