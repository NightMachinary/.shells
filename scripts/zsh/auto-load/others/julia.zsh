##
function jpre() {
    # jrm
    eval "prefix-files $1:q ${jpredicate:-*(D.)}"
}
function jvoice() {
    jpre "voicenote-"
}
jvideo() jpre "videonote-"
aliasfn jvid jvideo
jdoc() jpre "fdoc-"
jstream() jpre "streaming-"
##
function jsummon() {
    mkdir -p ~/julia_tmp/
    local u=(*)
    mv "$u" ~/julia_tmp/
    realpath ~/julia_tmp/"$u"
}
function junsummon() {
    \rm -r ~/julia_tmp
}
jdlc() {
    cp -r "$(last-modified ~/Downloads/)" ./
    jup
    # silence pushd ~/Downloads/
    # ge_ecdbg=y onlm get-dl-link
    # silence popd
}
jdl-helper() {
    mkdir -p ~/Downloads/tmp/
    cp "$1" ~/Downloads/tmp/
    get-dl-link ~/Downloads/tmp/"${1:t}"
    ec $'\n'
}
jdl() {
    jglob
    # dl_base_url="http://$(myip):8080/"
    re jdl-helper "$@"
}
jaaks() {
    jee
    aa "$@"
    local ag_f=(*)
    aget 'jks ; jup ../'
}
jks() {
    #ecdbg entering jks with jufile "$jufile"
    jglob  #jej
    #ecdbg trying to set orig
    local orig="$1" #(*)
    #ecdbg orig: "$orig"
    k2pdf-split "$orig"
    #ecdbg "trying to rm $orig"
    \rm "$orig"
    re p2ko *.pdf
}
ensure-ju() {
    test -e "$jufile" || { ecerr "jufile doesn't exist"
                           return 1 }
    local files=(*)
    test -e "$files" || { ecerr "jufile error: $jufile"
                          return 1 }
}
jmv() {
    # No longer needed, I think. You can now touch the file to resend it.
    test -e "$jufile" && mv "$jufile" "n_$jufile"
}
jrm() {
    test -e "$jufile" && \rm "$jufile"
}
jopus() {
    jglob
    local u="$1"
    ffmpeg -i "$u" -strict -2 "${u:r}.opus"
    command rm "$u"
    jvoice #actually unnecessary as Telegram sees most (size threshold probably) opus audio as voice messages:))
}
jup() {
    globexists ./**/*(.D) || return 0
    #rex "mv _ ${1:-./}" ./**/*(.D)
    #possibly silence it
    mv ./**/*(.D) "${1:-./}"
}
jimg() {
    test "$1" = "-h" && {
        ec 'googleimagesdownload --keywords "Polar bears, baloons, Beaches" --limit 20
googleimagesdownload -k "Polar bears, baloons, Beaches" -l 20

--format svg
-co red : To use color filters for the images
-u <google images page URL> : To download images from the google images link
--size medium --type animated
--usage_rights labeled-for-reuse
--color_type black-and-white
--aspect_ratio panoramic
-si <image url> : To download images which are similar to the image in the image URL that you provided (Reverse Image search).
--specific_site example.com
'
        return
    }
    googleimagesdownload "$@" && jup
}
function sdlg() {
    #use with aget
    spotdl "$@" && spotdl --no-encode -i m4a -f "${spotdl_dir:-.}/{artist} - {track-name}.{output-ext}"  -l *.txt && {
            mkdir -p ./ghosts/
            mv *.txt ./ghosts/
        }
}
function tsox() {
    silence ffmpeg -i "$1" "${1:r}".wav && sox "${1:r}".wav "${1:r}.$2" -G "${@:3}"
}
function vdsox() {
    local inp=(*)
    tsox "$inp" '2.wav' "$@" && silence swap-audio "$inp" "${inp:r}.2.wav" "${inp:r}.c.${inp:e}" && \rm -- ^*.c.${inp:e}
    silence jvideo
}
function vasox() {
    local inp=(*)
    tsox "$inp" 'c.mp3' "$@"
    \rm -- ^*.mp3
}
function vosox() {
    opusdec --force-wav * - 2> /dev/null | sox - "brave_n_failed.mp3" -G "$@"
    jrm
    silence jopus *
}
function vsox() {
    local inp=(*)
    sox "$inp" "${inp:r}_c.mp3" -G "$@"
}
function h_1jma() {
    local u="$(uuidgen)"
    local p=~/Downloads/"$u"/
    mkdir "$p"
    deluge-console add --move-path "$p" "$1"
    sleep "${jm_s:-60}"
    cp -r "$p" .
}
function jma() {
    jee
    zargs --max-procs 60 -n 1 -- "$@" -- h_1jma
    jup
    dir2k
}
noglobfn jma
function jah() {
    jahmode=y FORCE_INTERACTIVE=y reval "$@" | aha > "${jahout:-"${jd:-.}/$(<<<"$*" sd / _)".html}"
}
function jahun() {
    # unbuffer needs expect
    jah ruu unbuffer "$@"
}
jepubsplit() {
    jej
    jah dbg epubsplit $jufile
    rm $jufile
    dir2k
}
function jy() {
    local engine=("${jyE[@]:-y}")
    jee
    sout "$engine[@]" "$@"
    jrabbit="talks/$jrabbit" jdlrc *
    rm *
}
noglobfn jy
alias jys="jyE=ysmall jy"
function jyl() {
    # jylist
    ylist "$1" | jrabbit="${*[2,-1]}" inargsf re jys # re is needed to free up space
}
alifn jylist=jyl
noglobfn jyl jylist
