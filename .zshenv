#I am basically using this as shared config between zsh and bash. :D

source "$HOME/.privateShell"

function addToPATH {
    case ":$PATH:" in
        *":$1:"*) :;; # already there
        *) PATH="$1:$PATH";; # org/r PATH="$PATH:$1"
    esac
}

addToPATH "/Library/TeX/texbin"
addToPATH "$HOME/.cargo/bin"
addToPATH "/usr/local/bin"
#addToPATH "/usr/local/lib"
addToPATH "$HOME/.local/bin"
addToPATH "/Base/- Code/Resources/"
addToPATH "$HOME/go/bin"
addToPATH "/usr/local/opt/texinfo/bin"
addToPATH "$HOME/kscripts/"

export corra="198.143.181.104"
alias ccorra="echo -n $corra | pbcopy"
export sgate="198.143.181.179"
alias csgate="echo -n $sgate | pbcopy"
export HISTSIZE=100000
export HISTTIMEFORMAT="%m/%d/%Y %T " #I always tend to configure my machines with an large HISTSIZE value so it keeps a longer history list, as well as HISTTIMEFORMAT with the time stamp value so I can see when was the command ran.
export ALTERNATE_EDITOR="" #Causes Emacs to start a daemon if one is not found.
export SUDO_EDITOR="emacsclient"
export MONO_GAC_PREFIX="/usr/local"
export VISUAL='emacsclient -t'
export EDITOR="$VISUAL"
export LDFLAGS=-L/usr/local/opt/texinfo/lib
export ELM_HOME="/usr/local/bin/"
export JAVA_HOME8=`/usr/libexec/java_home --version 1.8`
export JAVA_HOME9=`/usr/libexec/java_home --version 9`
export JAVA_HOME=$JAVA_HOME8
addToPATH $JAVA_HOME
export BOOT_CLOJURE_VERSION='1.9.0' 

export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
#export PKG_CONFIG_PATH= "/usr/local/opt/zlib/lib/pkgconfig:/usr/local/lib/pkgconfig:/opt/X11/lib/pkgconfig"

alias table2ebook='\wget -r -k -c --no-check-certificate -l1' #recursive convert_links continue recursive_depth
alias coursera='coursera-dl -n -pl --aria2 --video-resolution 720p --download-quizzes --download-notebooks -sl "en,fa" --resume'
alias ox='zdict -dt oxford'
alias wh='which'
alias rqup='wg-quick up ~/Downloads/rq.conf'
alias rqdown='wg-quick down ~/Downloads/rq.conf'
alias wifi='osx-wifi-cli'
alias youtube-dlg="$HOME/anaconda/envs/wx3/bin/youtube-dl-gui"
alias last-created='\ls -AtU|head -n1' #macOS only
alias last-accessed='\ls -Atu|head -n1' #macOS only
alias last-modified='\ls -At|head -n1'
alias milli="mill mill.scalalib.GenIdeaModule/idea"
alias et="etlas exec eta"
alias et7="~/.etlas/binaries/cdnverify.eta-lang.org/eta-0.7.0.2/binaries/x86_64-osx/eta"
alias pe="pkill -SIGUSR2 Emacs"
alias ls="ls -aG"
alias ocr="pngpaste - | tesseract stdin stdout | pbcopy; pbpaste"
alias cask="brew cask"
alias bi="brew install"
alias ci="brew cask install"
alias fplay='ffplay -autoexit -nodisp -loglevel panic'
alias weather="wego | less -r"
alias j8='export JAVA_HOME=$JAVA_HOME8; export PATH=$JAVA_HOME/bin:$PATH'
alias j9='export JAVA_HOME=$JAVA_HOME9; export PATH=$JAVA_HOME/bin:$PATH'
alias emacsi="brew install emacs-plus --HEAD --with-24bit-color --with-mailutils --with-x11 --without-spacemacs-icon"
alias emc="emacsclient -t"
alias emcg="emacsclient -c"
alias y="youtube-dl "
alias enhance='function ne() { sudo docker run --rm -v "$(pwd)/`dirname ${@:$#}`":/ne/input -it alexjc/neural-enhance ${@:1:$#-1} "input/`basename ${@:$#}`"; }; ne'
alias image="image-to-ascii -i"
alias h="history | grep"

ks () { kscript ~/kscripts/"$@"; }

cdm ()
{
    mkdir -p -- "$1" &&
        cd -P -- "$1"
}

function cdd () { [ -f "$1" ] && { cd "$(dirname "$1")"; } || { cd "$1"; } ;}
. ~/anaconda/etc/profile.d/conda.sh #/Users/evar/anaconda/etc/profile.d/conda.sh
conda activate
set -o vi

#
# Defines transfer alias and provides easy command line file and folder sharing.
#
# Authors:
#   Remco Verhoef <remco@dutchcoders.io>
#

curl --version 2>&1 > /dev/null
if [ $? -ne 0 ]; then
    echo "Could not find curl."
    return 1
fi

transfer() { 
    # check arguments
    if [ $# -eq 0 ]; 
    then 
        echo "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"
        return 1
    fi

    # get temporarily filename, output is written to this file show progress can be showed
    tmpfile=$( mktemp -t transferXXX )
    
    # upload stdin or file
    file=$1

    if tty -s; 
    then 
        basefile=$(basename "$file" | sed -e 's/[^a-zA-Z0-9._-]/-/g') 

        if [ ! -e $file ];
        then
            echo "File $file doesn't exists."
            return 1
        fi
        
        if [ -d $file ];
        then
            # zip directory and transfer
            zipfile=$( mktemp -t transferXXX.zip )
            cd $(dirname $file) && zip -r -q - $(basename $file) >> $zipfile
            curl --progress-bar --upload-file "$zipfile" "https://transfer.sh/$basefile.zip" >> $tmpfile
            rm -f $zipfile
        else
            # transfer file
            curl --progress-bar --upload-file "$file" "https://transfer.sh/$basefile" >> $tmpfile
        fi
    else 
        # transfer pipe
        curl --progress-bar --upload-file "-" "https://transfer.sh/$file" >> $tmpfile
    fi
    
    # cat output link
    cat $tmpfile

    # cleanup
    rm -f $tmpfile
}

addToPATH "/usr/local/opt/curl/bin"
GPG_TTY=$(tty)
export GPG_TTY
eval $(thefuck --alias c)
eval "$(fasd --init auto)"
# export TERM=xterm-24bits
unalias run-help
autoload run-help

. /Users/evar/torch/install/bin/torch-activate

function git_sparse_clone() (
    # git_sparse_clone "http://github.com/tj/n" "./local/location" "/bin"
    rurl="$1" localdir="$2" && shift 2

    mkdir -p "$localdir"
    cd "$localdir"

    git init
    git remote add -f origin "$rurl"

    git config core.sparseCheckout true

    # Loops over remaining args
    for i; do
        echo "$i" >> .git/info/sparse-checkout
    done

    git pull origin master
)

function rloop_vid() ( 
    ffmpeg -i "$1" -filter_complex "[0:v]reverse,fifo[r];[0:v][r] concat=n=2:v=1 [v]" -map "[v]" "$1_rloop.${2:-mp4}"
)

function trr() (
    peerflix "$1" --path ~/Downloads/Video --mpv -- --fullscreen
)
function ot-mp3() (
    B=$(basename "$1"); D=$(dirname "$1");
    ffmpeg -ss 1.5 -i "$1" -metadata artist="Our Apparitions" -metadata title="${B%.*}" -codec:a libmp3lame -qscale:a 1 "$D/${B%.*}.mp3" "${@:2}"
    ffmpeg -ss 1.5 -i "$1" -metadata artist="Our Apparitions" -metadata title="${B%.*}" -codec:a copy "$D/${B%.*}.trimmed.wav" "${@:2}"
)
function ot-wav() {
    B=$(basename "$1"); D=$(dirname "$1");
    ffmpeg -ss 1.5 -i "$1" -metadata artist="Our Apparitions" -metadata title="${B%.*}" -codec:a copy "$D/${B%.*}.trimmed.wav" "${@:2}"
}

function mp3-to-mp4() (
    B=$(basename "$1"); D=$(dirname "$1");
    ffmpeg -loop 1 -i "$2" -i "$1" -pix_fmt yuv420p -c:v libx264 -crf 16  -c:a libfdk_aac -vbr 5 -preset veryslow -vf pad="width=ceil(iw/2)*2:height=ceil(ih/2)*2:x=0:y=0:color=black" -shortest "${3:-$D/${B%.*}}.mp4"
    # -c:a copy -r 1
    )
function sleepnow() ( sleep "${1:-7}"; pmset sleepnow )
silent_background() {
    { 1>/dev/null 2>&1 3>&1 eval "$@"& }
    disown &>/dev/null  # Prevent whine if job has already completed
}
function rm-alpha() {
    local B=$(basename "$1"); local D=$(dirname "$1");
    convert "$1" -background "$2" -alpha remove "$D/${B%.*}_$2.png"
}
function alpha2black() (rm-alpha "$1" black)
function alpha2white() (rm-alpha "$1" white)
function run-on-each() {
    for i in "${@:2}"
    do
        eval "$1 $i"
    done
}
function combine-funcs() {
    # Combine multiple functions into one named by $1; The result will run all functions with $@.
    local tmp321_string="function $1() { "
    for i in "${@:2}"
    do
        tmp321_string="$tmp321_string""$i "'"$@"; '
    done
    tmp321_string="$tmp321_string""}"
    # echo "$tmp321_string"
    eval "$tmp321_string"
}
function hi10-multilink() {
    #zsh-only
    local argCount=$#
    local pArgs=()
    for (( i=1; i<=$argCount; i+=1 ))
    do
        if [[ "$argv[i]" =~ '.*http:\/\/ouo.io\/s\/166CefdX\?s=(.*)' ]]; then
            # echo $match[1]
            pArgs[$i]=$match[1]
        else
            echo Invalid link: "$argv[i]"
        fi
    done
    # echo $pArgs
    # --referer="$1" is not needed now, if needed be sure to use regex matching to give it, as the urls returned from lynx are invalid.
    aria2c -j10 -Z  $pArgs 
}
function hi10-from-page() {
    # You need to have persistent cookies in lynx, and have logged in.
    hi10-multilink "${(@f)$(lynx -cfg=~/.lynx.cfg -cache=0 -dump -listonly $1|grep -E -i ${2:-'.*\.mkv$'})}"
    # eval 'hi10-multilink ${(@f)$(lynx -cfg=~/.lynx.cfg -cache=0 -dump -listonly "'"$1"'"|grep -E -i "'"${2:-.*\.mkv$}"'")}'
}
function ls-by-added() {
    mdls -name kMDItemFSName -name kMDItemDateAdded -raw "$(find .)" | \
        xargs -0 -I {} echo {} | \
        sed 'N;s/\n/ /' | \
        sort
}
