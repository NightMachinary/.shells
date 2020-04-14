function jprocs() {
	jah procs -c always "$@"
}
function jprocs-pic() {
	procs "$@" | convert -page  4000x4000 -font FreeMono -pointsize 20 -fill black -background white -trim +repage -bordercolor white  -border 15 text:- png:"$0 $*".png
	jdoc
}
function getidle-darwin() {
    ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF/1000000000; exit}'
}
function  getlastunlock-darwin() {
    date="$(log show --style syslog --predicate 'process == "loginwindow"' --debug --info --last 1d | command rg "going inactive, create activity semaphore|releasing the activity semaphore" | tail -n1 |cut -c 1-31)" fromnow
}
function ecdate() { ec "$edPre$(color 100 100 100 $(dateshort))            $@" }
