alias tsmf='tsendf $me'
###
function tsendf() {
    
    local f
    for f in "${@:2}"
    do
        tsend "$1" '' -f "$f"
    done
}
air() { zargs -i ___ -- "$@" -- tsendf ___ "$(mpv-get)"}
function reval-tlg() {
    mdoc 'enve; The Enveloper ^_^
An enhancer that sends stdout asynchronously to my Telegram. Also prints stdout.
Usage: me= enve command ...' MAGIC
    local out="$(eval "$(gquote "$@")")"
    ec "$out"
    tsend $me "$out" &
}
# aliasfn reval-tlg enve
function tlg-file-captioned() {
    local files=("$@") file
    local rec="$me"

    for file in $files[@] ; do
        file="$(realpath --relative-to $PWD "$file")"
        tsend --file "$file" -- "$rec" "$file"
        ec "Sent $file to $rec"
    done
}
