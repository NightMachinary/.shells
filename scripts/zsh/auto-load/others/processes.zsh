function pk() {
    pgrep -i "$@"
    pkill -9 -i "$@"
}
##
function ps-children() {
    pgrep -P "$1"
}
function ps-grandchildren() {
  local children=( $(ps-children "$1") ) pid

  arrN "$children[@]" '' # The output's ordering crucially depends on the position of this statement

  for pid in $children[@]
  do
    "$0" "$pid"
  done
}
function kill-withchildren() {
    local sig=2
    if [[ "$1" =~ '-\d+' ]] ; then
        sig="$1"
        shift
    fi
    local pids=("$@") pid


    for pid in "$pids[@]" ; do
        local children=("${(@f)$(ps-grandchildren "$pid")}") child
        kill -$sig "$pid" "$children[@]"
    done
}
##
