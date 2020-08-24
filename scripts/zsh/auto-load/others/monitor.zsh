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
function jprocs() {
    jah procs -c always "$@"
}
function jprocs-pic() {
    procs "$@" | text2img "$0 $*"
    jdoc
}
function getidle-darwin() {
    ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF/1000000000; exit}'
}
function  getlastunlock-darwin() {
    date="$(log show --style syslog --predicate 'process == "loginwindow"' --debug --info --last 1d | command rg "going inactive, create activity semaphore|releasing the activity semaphore" | tail -n1 |cut -c 1-31)" fromnow
}
function ecdate() { ec "$edPre$(color 100 100 100 $(dateshort))            $@" }
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
    system_profiler SPAudioDataType | command rg --quiet Headphones
}
aliasfn is-headphones headphones-is
