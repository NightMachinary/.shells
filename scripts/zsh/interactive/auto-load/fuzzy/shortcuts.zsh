###
function play-tag() {
    local f="$1"
    # tag --add green "$f"
    ntag-add "$f" green
    rgeval mpv "$(realpath "$ntag_add_dest")" # realpath to unbreak rgeval's usefulness because we use this via `indir`.
}
function openv() {
    local dirs=(${openv_dirs[@]}) query="$(fz-createquery "$@")"
    test -z "$dirs[*]" && dirs=(.)

    local i vids=''
    {
        # for i in "$dirs[@]" ; do
        #     # om sorts by moddate
        #     vids+="$(arrN $i/**/*.(${(j.|.)~video_formats})(.DNom))"
        # done

        # fd has nondeterministic sort order.
        vids="$(fd -uuu --type file --regex "\.(${(j.|.)video_formats})\$" "$dirs[@]")"
        dvar vids
        local prio=''
        prio="$(<<<$vids ntag-grepor green)" # to have these at first
        # ec --- ; arrN "$prio[@]" ; ec ---
        prio+="$(prefix-if-ne $'\n' "$(<<<$vids ntag-grepor aqua | prefixer rm -- "${(@f)prio}")")"
        # ec --- ; arrN "$prio[@]" ; ec ---
        prio+="$(prefix-if-ne $'\n' "$(<<<$vids ntag-grepor teal | prefixer rm -- "${(@f)prio}")")"
        # ec --- ; arrN "$prio[@]" ; ec ---
        prio+="$(prefix-if-ne $'\n' "$(<<<$vids ntag-grepor gray grey | prefixer rm -- "${(@f)prio}")")"
        # ec --- ; arrN "$prio[@]" ; ec ---

        ec $prio
        ec $vids | prefixer rm --skip-empty -- "${(@f)prio}"
    } | ntag-color | fz --ansi --query "$query" | inargsf play-tag
}
function delenda() {
    ntag-filterori red green aqua teal gray grey | inargsf trs
}
##
zv() {
    local q="$1" ; shift
    local query=("$@")

    if test -n "$q" ; then
        indir "$q" openv $query[@]
    else
        @opts dirs [ ~/base/cache ~/base/Lectures ~/base/series ~/base/anime ~/"base/_Local TMP" ~/base/docu ~/base/movies ~/base/V ~/base/dls ~/Downloads ] @ openv $query[@]
    fi
}
aliasfn r2 incache openv
lec() { indir ~/base/Lectures openv "$@" }
###
