## Vars
export mpv_ipc=~/tmp/.mpvipc
typeset -g MPV_AUDIO_NORM=--af-add='dynaudnorm=g=5:f=250:r=0.9:p=0.5'     # audio volume normalizer. See https://github.com/mpv-player/mpv/issues/6563
# typeset -g MPV_AUDIO_NORM=--af-add='loudnorm=I=-16:TP=-3:LRA=4' # alt


## Functions
function mpv() {
    local isStreaming="$mpv_streaming"

    local opts=()
    test -z "$isStreaming" && opts+="$MPV_AUDIO_NORM"
    command mpv $opts[@] --sub-auto=fuzzy --fs --input-ipc-server="$mpv_ipc" "${(0@)$(rpargs "$@")}"
}
function mpv-get() {
    <<<'{ "command": ["get_property", "'"${1:-path}"'"] }' socat - "${2:-$mpv_audio_ipc}"|jq --raw-output -e .data
}
mpv-getv() mpv-get "$1" "$mpv_ipc"
function play-and-trash(){
    #aliased to pat
    mpv "$@" && trs "$1"
}
function mpv-noidle() {
    set-volume 0
    silence mpv "$@" &
    local mympv=$!
    sleep 5
    # local i=0
    while true
    do
        set-volume 0
        (( $(getidle-darwin) >= 0.2 )) &&  {
            cleanbuffer
            kill -9 -$mympv # '-' makes it kill the whole process group. It's necessary.
            # pk mpv
            # print -n -- "\rKilling mpv for the ${i}th time ..."
            # i=$((i+1))
            # sleep 10 #interferes with silencing the volume
            break
            }
        sleep 0.1
    done
}
function yta() {
    mdoc "$0 <str> ...
Searches Youtube and plays the result as audio." MAGIC

    mpv --ytdl-format=bestaudio ytdl://ytsearch:"$*"
}
function mpv-cache() {
    mpv --force-seekable=yes --cache=yes --cache-secs=99999999 "$@"
}
function mpv-stream() {
    local file="$@[-1]"
    local opts=( "${@[1,-2]}" )
    # cache has been disabled in mpv.conf
    mpv_streaming=y mpv $opts[@] appending://"$file"
}
aliasfn mpvs mpv-stream
##
function retry-mpv() {
    # retry-eval "sleep 5 ; mpv --quiet $@ |& tr '\n' ' ' |ggrep -v 'Errors when loading file'"
    retry mpv-partial "${(Q)@}"
}
function mpv-partial() {
    ecerr "$0 started ..."
    local l=''
    # --quiet
    mpv "$@" |& {
        while read -d $'\n' -r l
        do
            color 50 200 50 "$l" >&2
            [[ "$l" =~ '(Cannot open file|Errors when loading file|Invalid NAL unit size)' ]] && { return 1 }
        done
    }
    return 0
}
##
playtmp() {
    mkdir -p ~/tmp/delme/
    cp "$1" ~/tmp/delme/
    color 0 200 0 Copied "$1" to tmp
    fsay Copied to tmp
    pat ~/tmp/delme/"$1:t"
}
function mpv-imgseq() {
    mpv "mf://*.png" --mf-fps 30
}
aliasfn mpvi mpv-imgseq
