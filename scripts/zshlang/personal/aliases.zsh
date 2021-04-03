isNotExpensive || {
    function zimportzlua() {
        zoxide import --merge ~/.zlua
    }
    export _ZO_DATA_DIR="$HOME/.z.dir"
    mkdir -p "$_ZO_DATA_DIR"
    if ((${+commands[zoxide]})) ; then
           eval "$(zoxide init zsh --no-aliases)" # --no-aliases: don't define extra aliases like zi, zq, za, and zr
           # `z -i` is fzf z.
    fi
    ##
    # export _ZL_ADD_ONCE=1
    # export _ZL_MATCH_MODE=1
    # antibody bundle skywind3000/z.lua
    ##
    ialiases[z]=y
    ## these are for zlua
    # ialias zz='z -c'      # restrict matches to subdirs of $PWD
    # alias zi='z -i'      # cd with interactive selection
    # ialias zf='z -I'      # use fzf to select in multiple matches
    # ialias zb='z -b'      # quickly cd to the parent directory
}
ialias zshrc='$=EDITOR ~/.zshrc'
ialias zshenv='$=EDITOR ~/.zshenv'
alias hrep="fc -El 0 | grep"
alias grep='grep --color=auto'

ialias plc=playlistc
alifn emc-gateway="emacsclient -t"
alifn emc="bicon-emc"
##
function emc-focus() {
    # How to give the focus to a specific tab? https://gitlab.com/gnachman/iterm2/-/issues/9602
    cliclick kd:cmd kp:num-5 ku:cmd # Took ~0.5
}
function emcnw() {
    emc-gateway --no-wait "$@"
    emc-focus
}
##
ialias emcg="emacsclient -c"
alias b='builtin'
alias typ='typeset -p'
alias n='noglob'
alias bs='brew search'
##
alias ci='curl --retry 120 --retry-delay 1 ipinfo.io' # ; ec ; myip ; mycountry' # ; px curl --retry 0 ipinfo.io'
# socks5h resolves hostname through proxy (I think). It's faster for my youtube test reqs:
# curl -x socks5h://127.0.0.1:1081 -o /dev/null -w %{url_effective}  'https://www.youtube.com/'
# curl -x http://127.0.0.1:1087 -o /dev/null -w %{url_effective}  'https://www.ipinfo.io/'
# curl -x socks5h://172.17.0.1:1081 -o /dev/null -w %{url_effective}  'https://www.ipinfo.io'
# curl -x http://172.17.0.1:1087 -o /dev/null -w %{url_effective}  'https://www.ipinfo.io/'
# time2 brishzr curl -o /dev/null -w %{url_effective}  'https://www.youtube.com/watch?v=5X5v7vRYQjc&list=PL-uRhZ_p-BM7dYrgeHz4r3u74L9xwyXmL'
# time2 curl -x socks5h://127.0.0.1:1078 -o /dev/null -w %{url_effective}  'https://www.ipinfo.io/'
aliasfn ci78 curl --retry 120 --retry-delay 1 -x 'socks5h://127.0.0.1:1078' https://ipinfo.io
aliasfn ci79 curl --retry 120 --retry-delay 1 -x 'socks5h://127.0.0.1:1079' https://ipinfo.io
aliasfn ci80 curl --retry 120 --retry-delay 1 -x 'socks5h://127.0.0.1:1080' https://ipinfo.io
aliasfn ci81 curl --retry 120 --retry-delay 1 -x 'socks5h://127.0.0.1:1081' https://ipinfo.io
aliasfn ci87 curl --retry 120 --retry-delay 1 -x 'http://127.0.0.1:1087' https://ipinfo.io
aliasfn ci88 curl --retry 120 --retry-delay 1 -x 'http://127.0.0.1:1088' https://ipinfo.io
aliasfn ci90 curl --retry 120 --retry-delay 1 -x 'socks5h://127.0.0.1:1090' https://ipinfo.io
##
alias pym='python -m'
alias pyc='python -c'
alias tsm='tsend $me'
alias kipy="pbcopy 'import os; os.kill(os.getpid(), 9)' #kill from within ipython embed"
# alias ta='tmux a -t' # fftmux might have made this irrelevant
alias agsf='ags -F'
alias ebk='ebook-viewer'
##
alias ltl='lt -l'
##
isDarwin && alias ncdu="ncdu --exclude 'Volumes' -x" # -x: Do not cross filesystem boundaries. using exclude patterns to avoid the infinite loop has not worked for me. beware that the loop can hog up all ram and then use swap space and fill up the disk completely.  --exclude-firmlinks also makes everything show up as zero.
alias mail='sudo less /var/mail/$(whoami)'
alias mcomix='awaysh python3 ~/bin/mcomixstarter.py'
##
alias pz='printz-quoted' # USEME for using zsh history suggestions effectively; E.g., `pz in doom sees`
##
alias o="@opts"
