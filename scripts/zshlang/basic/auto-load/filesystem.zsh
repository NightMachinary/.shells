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
##
function bottomdir() {
    { { [ -e "$1" ]  && ! [ -d "$1" ] } || { ! [ -e "$1" ] && [[ "$1" != */ ]] } } && { ec "${1:h}"; } || { ec "$1"; }
}
function bottomfile() {
    local name="$1"

    if test -n "$name" && ! test -d "$name" ; then
        local dir="$(bottomdir "$name")"
        ecn "$name" | prefixer -r "${dir}" | sd '^/*' ''
    fi
}
##
function dir-rmprefix() {
    local dir="$1" ; shift
    assert-args dir @RET

    prefixer --case-sensitivity no -r "$dir" "$@" | sd '^/*' ''
}
##
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
        if [[ "$(grealpath --  "$i")" == /Volumes/* ]] ; then
            if ask "$0: There seems to be external (cross-device) paths in args. Proceed with using normal mv instead?" Y ; then
                command gmv -i --verbose "$@"
                return $?
            fi
        fi
    done
    if (( ${#paths} <= 1 )) ; then
        ecerr "$0: Only one path supplied."
        return 1
    fi
    local opts=()
    isIReally && opts+='--interactive'
    command gcp -r --link --archive --verbose "${opts[@]}" "$@" || return $? #  --link option of the cp command, which creates hard links of files on the same filesystem instead of full-data copies. --archive preserve all metadata

    colorfg 170 170 170 ; trs "${(@)paths[1,-2]}" ; resetcolor
}
##
function list-dirs() {
    local d=(${@}) multi_fs="${list_dirs_m}" # multi = disable one-file-system
    local depth="${list_dirs_d}"

    local opts=()
    if test -z "$multi_fs" ; then
        opts+="--one-file-system"
    fi
    if test -n "$depth" ; then
        opts+=(--max-depth "$depth")
    fi
    arr0 $d[@] | filter0 test -d | inargs0 fd "$opts[@]" --follow --absolute-path --type d .
}
function list-dirs-d1() {
    ## @profile
    # `hyperfine --shell "brishz_para.dash" --warmup 5 --export-markdown=$HOME/tmp/hyperfine.md 'list-dirs-d1 ~/' 'arrN ~/*(/N)'`
    #     Benchmark #1: list-dirs-d1 ~/
    #   Time (mean ± σ):      33.8 ms ±  14.2 ms    [User: 0.7 ms, System: 0.6 ms]
    #   Range (min … max):    21.0 ms …  77.8 ms    22 runs
    #
    # Benchmark #2: arrN ~/*(/N)
    #   Time (mean ± σ):       6.6 ms ±  15.0 ms    [User: 1.0 ms, System: 0.7 ms]
    #   Range (min … max):     0.0 ms …  58.7 ms    28 runs
    #
    # Summary
    #   'arrN ~/*(/N)' ran
    #     5.14 ± 11.92 times faster than 'list-dirs-d1 ~/'
    ##
    list_dirs_d=1 list-dirs "$@"
}
##
