function glan() {
    # --time sets the refresh delay in seconds
    # --byte display network rate in byte per second
    glances --config ~/.glances --time 10 --theme-white --disable-webui --fs-free-space --byte --process-short-name "$@"
}
function fftop() {
    # linux: top -p
    # darwin: top -pid
    htop -p "${(j.,.)${(@f)$(ffps "$@")}}"
}
aliasfn pt fftop # process-top
##
function in-sum() {
    : "@alt num-utils: average, bound, interval, normalize, numgrep, numprocess, numsum, random, range, round"

    gawk '{s+=$1} END {printf "%.0f\n", s}'
    # https://stackoverflow.com/questions/450799/shell-command-to-sum-integers-one-per-line
}

##
function cpu-usage-get() {
    ps -A -o %cpu | awk '{s+=$1} END {print s "%"}'
}
function memory-free-get() {
    if isDarwin ; then
        ec $(( $({
                    vm_stat | rget 'Pages free:\s+(\d+)\.'
                    vm_stat | rget 'Pages speculative:\s+(\d+)\.'
                    vm_stat | rget 'Pages inactive:\s+(\d+)\.'
                } | in-sum) * $(vm_stat | rget 'page size of (\d+)') )) | numfmt-bytes
        ##
        # https://developer.apple.com/library/archive/documentation/Performance/Conceptual/ManagingMemory/Articles/AboutMemory.html
        #
        # - *Free memory:* This is RAM that's not being used.

        # - *Wired memory:* Information in this memory can't be moved to the hard disk, so it must stay in RAM. The amount of Wired memory depends on the applications you are using.

        # - *Active memory:* This information is currently in memory, and has been recently used.

        # - *Inactive memory:* This information in memory is not actively being used, but was recently used.

        # - *Used:* This is the total amount of memory used.
        #
        # By using purgeable memory, you allow the system to quickly recover memory if it needs to, thereby increasing performance. Memory that is marked as purgeable is not paged to disk when it is reclaimed by the virtual memory system because paging is a time-consuming process. Instead, the data is discarded, and if needed later, it will have to be recomputed.
    else
        @NA
    fi
}

##
function  pt-cpu-get() {
    procs --or "$@" | gtail -n +3 | awk '{print $4}' | in-sum
}
function  pt-cpu-get-grep() {
    procs | rg "$@" | awk '{print $4}' | in-sum
}
function pt-cpu-get-plus() {
    local q="$*" a
    if [[ "$q" =~ '^\d+$' ]] ; then
        pt-cpu-get "$q"
    else
            a=( ${(@f)"$(pgrep -f -i "$q")"} )
            if test -n "${a[*]}" ; then
                pt-cpu-get "$a[@]"
            else
                ec 0 # no process found so 0 cpu used by them
            fi
    fi
}
##
function t_cpu-get-lang-icon() {
    # did not work well. Buffering issues?
    procs | rg "input_lang_get_icon" | rg -v rg
}
##
function pt-cpu-i() {
    : "Supports multiple processes"
    local pids
    pids=("${(@f)$(ffps "$@")}") @RET

    lo_s=0.05 serr loop pt-cpu-get $pids[@] | plot-stdin
}
aliasfn ffcpu pt-cpu-i

function pt-cpu() {
    lo_s=0.05 serr loop pt-cpu-get-plus "$@" | plot-stdin
}
##
function ppgrep() {
    case "$(uname)" in
        Darwin)
            \pgrep -i "$@" | gxargs --no-run-if-empty ps -fp
            ;;
        Linux)
            \pgrep "$@" | gxargs --no-run-if-empty ps -fp
            # Linux's pgrep doesn't support -i
            ;;
    esac
}
##
function  jglan() {
    # doesn't work all that well (skips some newlines)
    fnswap glances 'gtimeout 10s unbuffer glances' glan | aha --line-fix > jglan.html # --black is worse
}
function jhtop() {
    gtimeout 1s htop | aha --line-fix --black > jhtop.html
}
function jprocs() {
    procs --pager disable --color always | aha --black > jprocs.html
}
function jprocs-pic() {
    procs "$@" | text2img "$0 $*"
    jdoc
}
##
function idle-get() {
    # output in seconds
    assert isDarwin @RET

    ioreg -c IOHIDSystem | sponge | awk '/HIDIdleTime/ {print $NF/1000000000; exit}'
}
function lastunlock-get() {
    assert isDarwin @RET

    # Using lower precision helps a lot with performance
    # hyperfine --warmup 5 "log show --style syslog --predicate 'process == \"loginwindow\"' --debug --info --last 3h" "log show --style syslog --predicate 'process == \"loginwindow\"' --debug --info --last 30h"
    local precision="${1:-1h}" # can only spot the last unlock in this timeframe
    [[ "$precision" =~ '^\d+$' ]] && precision+=h

    unset date
    date="$(assert revaldbg command log show --style syslog --predicate 'process == "loginwindow"' --debug --info --last "$precision" | command rg "going inactive, create activity semaphore|releasing the activity semaphore" | tail -n1 |cut -c 1-31)" || {
        # This means the last login was before the precision set
        ec 9999998
        return 0
    }

    date="$date" fromnow || {
        ectrace "$(retcode 2>&1)"
        ec 9999999
        return 1
    }
}
function lastunlock-get-min() {
    ec $(( $(lastunlock-get "$@") / 60 ))
}
##
function load5() {
    # 1 5 15 minutes
    sysctl -n vm.loadavg | awk '{print $3}'
}
function lsport() {
    local p opts=()
    for p in "$@" ; do
        opts+=(-i :"$p")
    done
    ((${#opts})) && sudo lsof -n $opts[@]
}
function headphones-is() {
    # @alt `hs.audiodevice.current().name`
    system_profiler SPAudioDataType | command rg --quiet Headphones
}
aliasfn is-headphones headphones-is
##
function lsof-openfiles() {
    local user="$(whoami)"
    ec "Total open files for $user: $(lsof -u "$user" | wc -l)"
    
    # sudo lsof -n | cut -f1 -d' ' | uniq -c | sort | tail -n30
    sudo lsof -n | cut -f1 -d' ' | gsort | guniq -c | gsort | tail -n30 # this merges different processes with the same name. idk what happens in the unmerged case exactly.
}
##
function screen-resolution() {
    : "outputs: width \n height"
    ensure isDarwin @MRET

    system_profiler SPDisplaysDataType | @opts r '$1'$'\n''$2' @ rget 'Resolution:\s*(\d+)\s*x\s*(\d+)'
}
function screen-width() {
    screen-resolution | ghead -n 1
}
function screen-height() {
    screen-resolution | gtail -n 1
}
##
function ps-parents-pid() {
    local pid="$1"
    assert-args pid @RET

    local ppid="$pid"
    while true ; do
        ppid="$(ps-parent-pid "$ppid")" @TRET
        if (( ppid == 1 )) ; then
            break
        fi
        ec "$ppid"
    done
}
function ps-parent-pid() {
    ps -fp "$1" | gtail -n1 | awkn 3
}
function ps-parents-print() {
    procs --tree --or "$@" | ansifold --width=$COLUMNS
    # you can add `--pager always --color always`, and remove ansifold. The colors don't play well with ansifold ...
}
function ffparents() {
    local pids
    pids=( ${(@f)"$(ffps "$@")"} ) @RET

    if (( $#pids >= 1 )) ; then
        reval-ec ps-parents-print $pids[@] @RET
    else
        return 1
    fi
}
function ps-parents-print1() {
    local pid="$1"
    assert-args pid @RET

    local ppids=( ${(@f)"$(ps-parents-pid "$pid")"} )

    ##
    assert command ps -fp "$pid" "$ppids[@]"
    ##
    # local i
    # for i in $ppids[@] ; do
    #     assert command ps -fp "$i"
    # done
    ##
}
function ffparents1() {
    local pid
    for pid in ${(@f)"$(ffps "$@")"} ; do
        reval-ec ps-parents-print "$pid" @RET
    done
}

##
function ps-zombies() {
    command ps axo pid=,stat= | gawk '$2~/^Z/ { print $1 }'
}
##
