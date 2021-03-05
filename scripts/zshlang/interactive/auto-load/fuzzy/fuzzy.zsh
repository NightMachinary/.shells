### SEE ALSO
# spotlight, spt, spot
###
# alias frc='frConfirm=y '
# alias cf='frc fi-d1'
# alias cfr='frc fi-rec'
function fr() {
    (( $#@ == 0 )) && return 1
    (( $#@ == 1 )) && set -- "$@" ''
    @opts query "${@[-1]}" @ fi-rec "$(gq "${@[1,-2]}")"
    hist-add-self
}
function fi-rec() {
    magic mdoc "[frConfirm='' frWidget=''] $0 <cmd> [<fd args> ...]
This function uses eval-memoi." ; mret

    local args=("${@:2}") query="$(fz-createquery $fi_rec_query[@])"
    local cmdhead="$1"
    local dir=.

    sels=( "${(@f)$(memoi_skiperr=y memoi_override_duration=0.3 eval-memoi fd "${fd_default[@]}" "${args[@]:-.}" "$(realpath "$dir")" |fz --cycle --query "$query")}" )
    test -n "$sels" && {
        if test -n "$frWidget" ; then
            LBUFFER="$LBUFFER$(gq "$sels[@]")"
        else
            local cmd=("$cmdhead $(gq "${sels[@]}")")
            if test -n "$frConfirm" ; then
                printz $cmd
            else
                geval $cmd
            fi
        fi
    }
}
aliasfn fr_zle frWidget=y fi-rec
aliasfn fr_zle_deus deusvult=y frWidget=y fi-rec
function fi-d1() fi-rec "$@" --max-depth 1 # freeing up f
##
function ffport() {
    doc "[fpFilter=.*] ffport <port> ..."

    local ports=("$@")
    local filter="${fpFilter:-.*}"

    lsport "$ports[@]" | { local line
                           read -d $'\n' -r line
                           ec "$line"
                           command rg "$filter"
    } | fz --with-nth '1,3,5,8,9..' --header-lines 1 | awk '{print $2}'
}
aliasfn ffportl fpFilter=LISTEN ffport
function ffps() {
    local query="$(fz-createquery "$@")"

    # ps auxww: List all running processes including the full command string
    ps auxww | fz --with-nth '11..' --header-lines 1 --query "$query" | awk '{print $2}'
}
function ffkill() {
    doc "alt: fkill; [fkEngine=ffps] ffkill ..."
    doc "Tip: fnswap kill 'sudo kill'"

    local engine=("${(@)fkEngine:-ffps}")
    local kill_engine=("${(@)ffkill_ke:-kill-withchildren}")
    ## Abandoned designs
    # local kg="${ffkill_group}" # kill the whole process group. (https://unix.stackexchange.com/a/14853/282382)
    # test -n "$kg" && kg='-'
    # | inargsf revaldbg mapg "${kg}"'${i}'
    ##

    local opts=()
    if [[ "$1" =~ '-\S+' ]] ; then
        opts+="$1"
        shift
    fi
    "$engine" "$@"  | inargsf revaldbg "$kill_engine[@]" $opts[@]
}
aliasfnq ffkill-super fnswap kill 'sudo kill' ffkill -9
aliasfn fk ffkill
aliasfn fks ffkill-super
aliasfnq fk-joker ffkill "'JOKER_MARKER"
aliasfn ffportlkill fkEngine=ffportl ffkill
aliasfn killport ffportlkill
function lsofp() {
    ffps "$@" | inargsf re "lsof -p" | less
    # Old:
    # ppgrep "$@" | fz --header-lines 1 | awk '{print $2}' | inargsf re "lsof -p" | less
}
aliasfn fflsof lsofp
aliasfn plsof lsofp
function fzinw() {
    doc 'fz in words: allows you to select the part of the output you need from a command. (alt: smenu?)'
    iaIFS=$' \t\n\C-@'"'"'(){}"[]' inargss arrN | fz
}
fftmux() {
    local query="$*"
    local engine=(tmux a -t)
    test -n "$ftE[*]" && engine=("$ftE[@]")
    local sessions
    sessions="$(tmux ls|fz --query "$query")" || return $?
    local i
    for i in "${(f@)sessions}"
    do
        [[ $i =~ '([^:]*):.*' ]] && {
            ec "acting on session $match[1]"
            reval "${engine[@]}" "$match[1]"
        }
    done
}
alias fft=fftmux
fftmuxkill() { ftE=(tmux kill-session -t) fftmux }
##
ffman() {
    # mnf
    man -k . | fz --prompt='Man> ' | awk '{print $1}' | rgx '\(\d+\)$' '' | gxargs -r man
}
alias ffm=ffman
ffaliases() {
    # also see aga
    for k in "${(@k)aliases}"; do
        ec "$k=${aliases[$k]}"
    done | fz --prompt='Aliases> '
}
alias ffa=ffaliases
ffcommands() {
    # cmf (previous name)
    # command finder
    printz "$(agc "${@:-.}" | fz --prompt 'Commands> ')"
}
alias ffc=ffcommands
fffunctions() {
    printz "$(agfunc "${@:-.}" | fz --prompt 'Functions> ')"
}
alias ff=fffunctions
###
function init-vfiles() {
    : GLOBAL vfiles

    if test -n "$*" || test -z "$vfiles[1]" ; then
        local i dirs=( "${(@0)$(arr0 ~/.julia/config ~/.julia/environments $DOOMDIR $NIGHTDIR $cellar $codedir/nodejs $codedir/lua $codedir/python $codedir/uni $codedir/rust $codedir/golang | filter0 test -e)}" )
        vfiles=( ${(0@)"$(fd -0 --ignore-file ~/.gitignore_global --exclude node_modules --exclude resources --exclude goog --ignore-case --type file --regex "\\.(${(j.|.)text_formats})\$" $dirs[@] )"} ~/.zshrc ~/.zshenv )
        # for i in "$dirs[@]" ; do
        #     vfiles+=( $i/**/*(.D^+isbinary) )
        # done
    fi

    # --ignore-file seems not working
}
aliasfn vinit init-vfiles yes
function v() {
    local emacs_root=~/.emacs.d.doom/.local # normal emacs doesn't have this .local part
    local emacs_recent="$emacs_root/.cache/recentf"
    : GLOBAL vfiles
    init-vfiles

    local files excluded=( ~/.zlua ~/.zsh_history "$HOME/.local/share/nvim/shada/main.shada" "$HOME/Library/Application Support/Code/storage.json" "$HOME/Library/Application Support/Code - Insiders/storage.json" "$HOME/Library/Application Support/Google/Chrome/Local State" )
    files=( "$vfiles[@]" )
    local code="$HOME/Library/Application Support/Code - Insiders/storage.json"

    test -f "$code" && {
        command rg --only-matching --replace '$1' '"file://(.*)"' "$code" |
            while read -d $'\n' -r line; do
                [ -e "$line" ] && {
                    files+="$line"
                    ecdbg "vscode: $line"
                }
            done
    }

    command rg '^>' ~/.viminfo | cut -c3- |
        while read -d $'\n' -r line; do
            line="${line/\~/$HOME}"
            [ -f "$line" ] && files+="$line"
        done
    test -f "$emacs_recent" && {
        command rg --only-matching --replace '$1' '^\s*"(.*)"$' "$emacs_recent" |
            while read -d $'\n' -r line; do
                [ -f "$line" ] && files+="$line"
            done
    }
    # files=( ${(@)files//\~/$HOME} ) # emacs doesn't need this
    # stat doesn't expand ~
    # sort files by modification date
    # %Y     time of last data modification, seconds since Epoch
    # reing gstat is needed if the files get too numerous, but then things will be too slow
    files=( ${(0@)"$(gstat  --printf='%040.18Y:%n\0' "${(@)files:|excluded}" | gsort --reverse --zero-terminated --unique | gcut -z -d':' -f2-)"} ${(@)excluded} ) #Don't quote this there is always a final empty element
    files=( ${(0@)"$(<<<"${(F)files}" fz --print0 --query "$*")"} ) || return 1
    local ve="$ve"
    reval "${veditor[@]}" "${(@)files}"
}
##
function vni() { fr "${veditor[@]}" . $NIGHTDIR }
aliasfn vc code-insiders --reuse-window --add # --add: Add a folder or multiple folders to the last active VS Code instance for a multi-root workspace.
function coder() {
    local p="$(<<<$1 sd "$HOME" /home/eva)"
    rgeval code-insiders --reuse-window --remote 'ssh-remote+82.102.11.148' "$p"
}
aliasfn vcr coder
##
aliasfn vr veditor=(coder) v
aliasfn vcode veditor=(code-insiders --reuse-window)
aliasfn ve veditor=(emc)
aliasfn vv ve v
###
function vp-ls() {
    arrN ~/Downloads/**/*.pdf ~/Base/_Books/**/*.pdf
}
function vp() {
    # v pdf
    vp-ls | fz | inargsf re open
}
##
