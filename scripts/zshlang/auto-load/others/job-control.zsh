##
function ensurerun() {
    ruu "retry gtimeout $1" "${@:2}"
}
function loop() {
    mdoc "Usage: [lo_s=<interval> lo_noinit=<skip-first-iteration> lo_p=<socket-to-startover> lo_sig2cancel=] $0 CMD
    Set lo_sig2cancel=y to terminate the whole loop when receiving a signal.
    If you need to be able to ctrl-c to just cancel the loop command (not the whole loop), you'll need to support it in your loop command. See the source of luna-advanced-bell for what needs to be done.
" MAGIC
    setopt localoptions localtraps
    # Well I couldn't debug this. Setting set +m is enough to cause bugs, but the other lines make things progressively worse ...
    # set +m
    local inter=${lo_s:-1}
    local cancelMode="$lo_sig2cancel"
    local cmd="$(gquote "${@}")"
    local lo_p="$lo_p"
    ensure-dir "$lo_p"

    >&2 chalk -t "{rgb(255,255,255).bgRgb(0,30,230) Looping {rgb(0,30,230).bgRgb(255,255,255) $cmd} with interval {rgb(255,73,28) $inter}}"
    local sig=1 neon c=0 sig2=0
    test -z "$lo_noinit" || {
        color 0 255 100 "$(colorbg 255 255 255)Skipping first iteration" >&2
        sig=0
    }
    test -n "$cancelMode" && {
        color 0 255 100 "$(colorbg 255 255 255)Loop will terminate if a signal is received." >&2
    }
    while (( sig2 != 666 )) && (( sig != 130 ))
    do
        (( sig )) && { eval "$cmd" ; c=$[c+1] }
        print -n "\r$(colorbg 0 30 230)$(colorfg 255 255 100)Iteration $c$(resetcolor)" >&2
        # </dev/null sleep-neon $inter &
        # neon=$!
        trap _loop_trap INT
        comment "We can't handle the signals when we are running a command; see https://unix.stackexchange.com/questions/24087/wrapper-program-that-sets-signal-handler"
        [[ -z "$lo_p" ]] && { sleep $inter ; sig=1 } || {
            gtimeout --preserve-status ${inter}s socat -u unix-listen:${lo_p},unlink-early -
            sig=$?
            if (( sig == 0 )) && test -n "$cancelMode" ; then
                return 0
            fi
        }
        trap - INT # resets to default
        # ec sig $sig >> a
        # kill $neon
    done
}
@opts-setprefix loop lo
##
function oneinstance-setup() {
    ensure-redis || return 1
    
    local someNonce="${1}"
    test -z "$someNonce" && { ecerr someNonce is empty. ; return 1 }
    someNonce="nonce_${someNonce}"

    ## Old way (vulnerable to race conditions)
    # (( $(redism exists $someNonce) )) || sout redis-cli set $someNonce 0
    # local nonce=$(( $(redism get $someNonce) + 1 ))
    # (( $nonce == 10000 )) && nonce=0
    ##
    local nonce="$(uuidm)"
    sout redis-cli set $someNonce $nonce
    ec $nonce
}
oneinstance() {
    local nonce="$2"
    test -z "$nonce" && { ecerr nonce is empty. ; return 1 }

    local someNonce="${1}"
    test -z "$someNonce" && { ecerr someNonce is empty. ; return 1 }
    someNonce="nonce_${someNonce}"

    [[ "$nonce" == "$(redism get $someNonce)" ]]
}

_loop_trap() {
    ec '
loop interrupted' ; sig2=666
}
loop-startover() { edPre=$'\n' ecdate "Signal from loop-startover${@:2}" | socat -u - unix-connect:${1} }
alias loops='loop-startover' #Oops :D
##
# function cancelable() {
#     # @todo0 @design make zsh functions cancelable. Useful for zopen.
# }
##
insubshell() {
    local cmd="$(gquote "$@")"
    insubshell-eval "$cmd"
}
@opts-setprefix insubshell insubshell-eval
insubshell-eval() {
    local cmd=("$@")
    local marker="${insubshell_eval_marker:-${insubshell_eval_m:-AWAYSH_MARKER}}"

    (
        mark-me "$marker" ${cmd[@]} # keep zsh at first so doing, e.g., `pkill zsh` still works
        # https://unix.stackexchange.com/questions/169987/update-process-name-in-shell-is-it-possible/170322#170322
        # The thing is a quite of a hack, and before using it, one basically is required to first run zsh with long parameter list, to reserve enough space for argv, to then be able to assign strings of that length.
        eval "$cmd[*]"
    ) &>/dev/null </dev/null
}
function mark-me() {
    local mark
    mark="$(ec "${${1:u}:-NA}" | gtr '-' '_')" @RET
    [[ "$mark" =~ '_MARKER$' ]] || mark+=_MARKER
    jobs -Z "zsh $mark $(gq "${@[2,-1]}")"
}
##
function awaysh-exit() {
    ##
    trap "" INT TERM HUP EXIT
    {
        (true)
    } always {
        awaysh1 "$@"
    }
    exit 0
    ##
    # awaysh1 "$@"
    # exit 0
    ##
}
function awaysh-doublefork() {
    # https://stackoverflow.com/questions/66936760/shell-fork-daemonize-a-subshell-such-that-it-survives-the-death-of-its-tmux-s
    awaysh1 awaysh-exit "$@"
}
function awaysh() {
    ( awaysh1 "$@" ) &>/dev/null </dev/null
    # subshell needed to silence messages generated from MONITOR (e.g., `[9] 5152`)
    # also, weirdly, with this subshell, we no longer need MONITOR in the first place :|
}
function awaysh-sure() {
    # @broken completely
    awaysh-doublefork "$@"
    # ( awaysh-exit "$@" )
    sleep 1 # give it time to fork
}
function awaysh1() {
    local cmd="$(gquote "$@")"

    setopt LOCAL_OPTIONS NO_NOTIFY
    # http://zsh.sourceforge.net/Doc/Release/Options.html#index-NO_005fMONITOR
    # http://zsh.sourceforge.net/Doc/Release/Options.html#index-NO_005fNOTIFY

    ##
    setopt NO_MONITOR # the subshell in awaysh makes this possible
    # note that without MONITOR, the forked children will, probably, still share their parent's process group ID.
    #
    # &| operator: It runs the given command in background, but the command is not a job, so your display is not spammed. You cannot use wait though.
    ( insubshell-eval "$cmd"  &| ) &|
    ##
    # setopt MONITOR
    # We might also need POSIX_JOBS to really activate this completely?
    # Without MONITOR, killing (signaling) the parent shell will kill these as well.
    #
    # ( insubshell-eval "$cmd"  & ; disown-true ) &
    # disown-true
    ##
}
function disown-true() {
    disown &>/dev/null || true  # Prevent whine if job has already completed
}
@opts-setprefix awaysh insubshell-eval
@opts-setprefix awaysh1 insubshell-eval
@opts-setprefix awaysh2 insubshell-eval
##
# awaysh() inbg silent "$@"
aliasfn inbg awaysh
##
function awaysh-named() {
    # note that somehow using simple commands like sleep will not retain the parent process (and so you can't see its name either), but wrapping that sleep in a function will keep the executing subshell alive. Idk why.
    insubshell_eval_marker="$1" awaysh "${@:2}"
}
function awaysh-bnamed() {
    brishz awaysh-named "$@"
}
function awaysh-bnamed-rp() {
    local name="${1:? Name required}" ; shift
    local args=("$@")

    transformer realpath-ife 'awaysh-bnamed "$name"' "$args[@]"

    ## old ways:
    # silent rpargs "$@"
    # awaysh-bnamed "$name" "$out[@]"
    ##
    #     local i cmd=()
    #     for i in "$args[@]" ; do
    #         if test -e "$i" ; then
    #             ec "Realpathing: $i"
    #             cmd+="$(realpath "$i")"
    #         else
    #             cmd+="$i"
    #         fi
    #     done
    #     awaysh-bnamed "$name" "$cmd[@]"
    ##
}
##
function insubshell-named() {
    @opts marker "$1" @ insubshell "${@:2}"
}
function insubshell-bnamed() {
    brishz insubshell-named "${@}"
}
##
function away() {
    : "Use awaysh, that seems better in every single case."

    ruu 'nohup --' "$@" &
    # disown is still needed. Without it you'll see `[1]  + 97327 done       nohup sleep 10`
    disown &>/dev/null  # Prevent whine if job has already completed
}
##
function kill-marker() {
    local id="${1:?}"

    pgrep -f "$id" | inargsf kill-withchildren
}
##
killjobs() {
    local kill_list="$(jobs)"
    if [ -n "$kill_list" ]; then
        # this runs the shell builtin kill, not unix kill, otherwise jobspecs cannot be killed
        # the `$@` list must not be quoted to allow one to pass any number parameters into the kill
        # the kill list must not be quoted to allow the shell builtin kill to recognise them as jobspec parameters
        kill $@ $(gsed --regexp-extended --quiet 's/\[([[:digit:]]+)\].*/%\1/gp' <<< "$kill_list" | tr '\n' ' ')
    else
        return 0
    fi
}
