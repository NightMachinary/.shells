alias lunar="lo_s=$((60*${1:-36})) lo_noinit=y lo_p=${2:-~/tmp/.luna} loop"
luna() {
    lunar pmset displaysleepnow
}
alias lq='loop-startover ~/tmp/.luna'
