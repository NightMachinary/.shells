isNotExpensive || {
    function zimportzlua() {
        zoxide import --merge ~/.zlua
    }
    export _ZO_DATA_DIR="$HOME/.z.dir"
    mkdir -p "$_ZO_DATA_DIR"
    eval "$(zoxide init zsh --no-aliases)" # --no-aliases: don't define extra aliases like zi, zq, za, and zr
    ##
    # export _ZL_ADD_ONCE=1
    # export _ZL_MATCH_MODE=1
    # antibody bundle skywind3000/z.lua
    ##
    ialiases[z]=y
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
alifn emc="emacsclient -t"
ialias emcg="emacsclient -c"
alias b='builtin'
alias typ='typeset -p'
alias n='noglob'
alias bs='brew search'
alias gray='tag --recursive --match Gray .|sort'
alias mg='tag --add Gray'
alias ci='curl ipinfo.io ; ec ; myip ; mycountry ; px curl --retry 0 ipinfo.io'
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
