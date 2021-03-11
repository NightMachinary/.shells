function realpath-relchild() {
    local dir="$1" mypath="$2"

    local rel="$(realpath --relative-to "$dir" "$mypath")"
    if [[ "$rel" =~ '^../' ]] ; then
        realpath "$mypath"
    else
        ec "$rel"
    fi
}
##
function cdm() {
    local d="$*"

    mkdir -p -- "$d" &&
        cd -P -- "$d"
}
function bottomdir() {
    { { [ -e "$1" ]  && ! [ -d "$1" ] } || { ! [ -e "$1" ] && [[ "$1" != */ ]] } } && { ec "${1:h}"; } || { ec "$1"; } ;}
function cdd() {
    cd "$(bottomdir "$1")"
}
function cdz() {
    local i="$*"

    if test -d "$i" ; then
        cd "$i"
    else
        ffz "$i"
    fi
}
##
function ensure-dir() {
    mkdir -p "$(bottomdir $1)"
}
reify ensure-dir
function lnrp() {
    local f="${1:?}" d="${2:?}"

    ln -i -s "$(realpath2 "$f")" "$d"
}
function rmdir-empty() {
    : "Removes all recursively empty directories from <root-dir>"

    local root="$1"
    if ! test -d "$root" ; then
        ecerr "$0: Non-existent root directory: $root"
        return 1
    fi
    # From https://unix.stackexchange.com/a/107556/282382
    gfind "$root" -mindepth 1 -type d -empty -delete
}
function append-f2f() {
    local from="$(realpath "$1")" to="$(realpath --canonicalize-missing "$2")"
    if [[ "${from:l}" == "${to:l}" ]] ; then # realpath --canonicalize-missing does not normalize the case in macOS, so we are forcing them both to lowercase.
        ecerr "$0: Destination is the same as the source. Aborting."
        return 1 # We rely on this not being zero
    fi
    ensure-dir "$to"
    cat "$from" | sponge -a "$to"
}
##
function  mv-merge() {
    # https://unix.stackexchange.com/questions/127712/merging-folders-with-mv/172402
    local paths=() i opts_end
    for i in "$@" ; do
        if [[ -n "$opts_end" || "$i" != '-'* ]] ; then
            paths+="$i"
        fi
        if [[ "$i" == '--' ]] ; then
            opts_end=y
        fi
    done
    if (( ${#paths} <= 1 )) ; then
        ecerr "$0: Only one path supplied."
        return 1
    fi
    command gcp -r --link --archive --interactive --verbose "$@" || return $? #  --link option of the cp command, which creates hard links of files on the same filesystem instead of full-data copies. --archive preserve all metadata

    colorfg 170 170 170 ; trs "${(@)paths[1,-2]}" ; resetcolor
}
##