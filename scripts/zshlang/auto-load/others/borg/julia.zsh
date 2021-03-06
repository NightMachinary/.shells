##
jkey_expire=$((3600*24*60))
function jtokey() {
    local key="${1?Key required}" cmd="${2?Cmd required}" jjson="${3}" jjson_btn="${4}" jdata="${5}" jaction="${6}"

    cmd="$(redism hset "$key" cmd "$cmd")"
    jjson="$(redism hset "$key" jjson "$jjson")"
    jjson_btn="$(redism hset "$key" jjson_btn "$jjson_btn")"
    jdata="$(redism hset "$key" jdata "$jdata")"
    jaction="$(redism hset "$key" jaction "$jaction")"
    redism expire "$key" "$jkey_expire"
}
function jfromkey() {
    local key="${1?Key required}"

    local cmd jjson jdata
    cmd="${$(redism hget "$key" cmd):?Empty cmd}"
    jjson="$(redism hget "$key" jjson)"
    jjson_btn="$(redism hget "$key" jjson_btn)"
    jdata="$(redism hget "$key" jdata)"
    jaction="$(redism hget "$key" jaction)"
    silent redism expire "$key" "$jkey_expire" # this way used commands don't die

    local res="$(eval "$cmd" 2>&1)"
    arr0 "$res" "$jaction"
}
##
function jiarr() {
    if (( $#@ == 0 )) ; then
        set -- "${(@f)$(cat)}"
    fi

    local i results=()
    for i in $@ ; do
        results+="$(jq --null-input --compact-output --arg i "${i}" '{ tlg_title: $i, tlg_content: $i }')"
    done
    arrJ-noquote "$results[@]"
}
##
function html-esc() {
    gsed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
    # ALT: recode ascii..html
}

function jigoo() {
    local query="$*"

    local goo_urls goo_titles goo_asbtracts goo_metadata
    silent @opts c 11 @ goo-g "$query" || return 1 # outputs in global vars
    local i r=() o
    for i in {1..${#goo_urls}} ; do
        # r+="$(readmoz_nosummary=y readmoz-md "$goo_urls[$i]" | jq --raw-input --slurp --null-input --compact-output --arg title "$goo_titles[$i]" 'inputs as $i | {"tlg_title": $title, "tlg_content": $i, "tlg_parsemode": "md"}')"
        o="<a href=\"$goo_urls[$i]\" ><b>$(<<<${goo_titles[$i]} html-esc)</b></a>"$'\n\n'"$(<<<${goo_abstracts[$i]} html-esc)"
        if [[ "$goo_metadata[$i]" =~ '\S' ]] ; then
            o+=$'\n\n'"<i>$(<<<$goo_metadata[$i] html-esc)</i>"
        fi
        r+="$(print -nr -- $o | jq --raw-input --slurp --null-input --compact-output --arg title "$goo_titles[$i]" 'inputs as $i | {"tlg_title": $title, "tlg_content": $i, "tlg_parsemode": "html"}')"
    done

    arrJ-noquote $r[@]
}
##
function jivid() {
    # j inline video
    local vids=( ./$~videoglob ) f url results=()
    for f in $vids[@] ; do
        url="$(jdl "$f")"
        results+="$(jq --null-input --compact-output --arg url "$url" --arg f "${f:t}" '{ tlg_title: $f , tlg_video: $url }')"
    done
    arrJ-noquote "$results[@]"
}
function jiy() {
    jee

    silent ymp4 "$@"
    jivid
    silent command rm *(N)
}
noglobfn jiy
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
    local subdir="${jdl_subdir:-tmp}"

    mkdir -p ~/Downloads/$subdir/
    cp "$1" ~/Downloads/$subdir/
    get-dl-link ~/Downloads/$subdir/"${1:t}"
    ec $'\n'
}
function jdl() {
    jglob
    # dl_base_url="http://$(myip):8080/"
    re jdl-helper "$@"
}
function jdl-private() {
    jdl_subdir="private" jdl "$@"
}
##
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

    : "@example pkno @opts odpi 275 rtl y @ jks"
}
@opts-setprefix jks k2pdf
##
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
    command mv --update ./**/*(.D) "${1:-./}"
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
##
function tsox() {
    # @alt audiofx-sox
    silence ffmpeg -i "$1" "${1:r}".wav && sox "${1:r}".wav "${1:r}.$2" -G "${@:3}"
}
function vdsox() {
    local inp=(*)
    tsox "$inp" '2.wav' "$@" && silence swap-audio "$inp" "${inp:r}.2.wav" "${inp:r}.c.${inp:e}" && \rm -- ^*.c.${inp:e}
    silence jvideo
}
function vasox() {
    ## usage example:
    # vasox speed 1.3 : pitch 500 : reverb
    ##
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
##
function h_1jma() {
    local u="$(uuidgen)"
    local p=~/Downloads/"$u"/
    mkdir "$p"
    deluge-console add --move-path "$p" "$1"
    sleep "${jm_s:-300}"
    gcp --verbose -r "$p" .
}

function jma() {
    jee
    zargs --max-procs 60 -n 1 -- "$@" -- h_1jma
    jup
    dir2k
}
noglobfn jma
##
function jah() {
    jahmode=y FORCE_INTERACTIVE=y reval "$@" | aha > "${jahout:-"${jd:-.}/$(<<<"$*" sd / _)".html}"
}
function jahun() {
    # unbuffer needs expect
    jah ruu unbuffer "$@"
}
##
jepubsplit() {
    jej
    jah dbg epubsplit $jufile
    rm $jufile
    dir2k
}
##
function jy() {
    # youtube-dl to gdrive
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
##
function reval-2json() {
    local out="$(gmktemp)"
    local err="$(gmktemp)"
    FORCE_NONINTERACTIVE=y reval "$@" > "$out" 2> "$err"
    local ret=$?
    cat "$out" | jq --raw-input --slurp --null-input --arg ret "$ret" --slurpfile err <(cat "$err" | jq --raw-input .) 'inputs as $i | {"retcode": $ret, "stdout": $i, "stderr": $err}' # --compact-output
}
##
