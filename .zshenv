##
ZSH_PWD_CACHE=~/tmp/.zsh_pwd
function zsh-pwd-save() {
    if test -z "$HISTFILE" ; then
        return 0
    fi

    print -r -- $PWD > "$ZSH_PWD_CACHE"
}
function zsh-pwd-load() {
    local d
    d="$(cat "$ZSH_PWD_CACHE" 2>/dev/null)" || return 0
    if test -d "$d" ; then
        cd -- "$d"
    fi
}
if [[ -o interactive ]] ; then
    zsh-pwd-load
fi
##
test -z "$ZSH_PROFILEME" || zmodload zsh/zprof # use zprof -c to reset counters
# Does not profile internals of functions well.
#
# `ZSH_PROFILEME=y zsh -c 'zprof > ~/tmp/a'`
#
# Visualize:
#  `zprof  | gprof2dot -f perf | dot -Tpng -o output.png`
#  Did not work because of a unicode error :shrugs:
##
# module_path+=( "/Users/evar/.zinit/mod-bin/zmodules/Src" )
# zmodload zdharma/zplugin
# Doesn't work with aliases
##
# export disable_malice=''
export disable_malice='y'
export NIGHT_PERSONAL=y
source "$HOME/scripts/zshlang/load-first.zsh"
typeset -g NIGHT_NO_EXPENSIVE
isNotExpensive || {
    source ~/.shared.sh

    export HH_CONFIG=hicolor
    ##
    # export GERBIL_HOME="$(brew --cellar gerbil-scheme)" # @exorbitant
    if isDarwin ; then
        export GERBIL_HOME=/usr/local/Cellar/gerbil-scheme/0.16/
        # not sure if this is even right
    fi
    ## 
    # this is a TCL list https://wiki.tcl-lang.org/page/list , uses whitespace as sep
    #isLinux && export TCLLIBPATH=/usr/lib/x86_64-linux-gnu
    isLinux && export TCLLIBPATH="$TCLLIBPATH /home/linuxbrew/.linuxbrew/lib"
    isDarwin && export TCLLIBPATH="/usr/local/lib" # for expect to work
    ##
    source <(antibody init)
    ANTIBODY_HOME="$(antibody home)"
    DISABLE_DEFER=y
    # Won't defer if not interactive or disabled explicitly
    { [[ -o interactive ]] && test -z "$DISABLE_DEFER" } && antibody bundle romkatv/zsh-defer || alias zsh-defer=''
    source-interactive-all() {
        run-on-each source "$NIGHTDIR"/zshlang/interactive/auto-load/**/*(.)
        source "$NIGHTDIR"/zshlang/interactive/completions.zsh # needs to be semi-last
        typeset -g NIGHT_NO_EXPENSIVE
        NIGHT_NO_EXPENSIVE=y
    }
    function realpath2() {
        test -e "$1" && realpath -e "$1" || {
                (( ${+commands[$1]} )) && realpath -e "${commands[$1]}"
            }
        ##
        # -e, --canonicalize-existing: all components of the path must exist
        ##
    }
    function rp() {
        realpath2 "$@"
    }
}
test -n "$NO_AUTOLOAD_BASH" || zsh-defer source "$NIGHTDIR"/bash/load-others.bash

if isKitty ; then
    function kitty-fix-path() {
        preexec_functions[$preexec_functions[(i)kitty-fix-path]]=()
        source ~/.shared.sh
    }
    preexec_functions+=kitty-fix-path
fi
