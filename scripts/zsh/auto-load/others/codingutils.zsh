preEnhNames() {
    mdoc "$0 args ...
Replaces any arg that is in enhSavedNames with its original name. Outputs in \$out.
Update: Actually adds, not replaces. Also removes duplicates." MAGIC

    local items=( "$@" )
    local itemsP=()
    for item in "$items[@]"
    do
        local on="$enhSavedNames[$item]"
        itemsP+="$item"
        if test -n "$on" ; then
            itemsP+="$on"
        else

        fi
    done
    out=("${(u@)itemsP}")
}
whichm() {
    preEnhNames "$@"
    local item output
    for item in "$out[@]"
    do
        output="${aliases[$item]}" ; test -n "$output" && {
            output="$(gq "$output")"
            ec "alias $item=$output"
            local is=("$output")
            is+=( ${$(fnswap expand-aliases expand-alias expand-alias-strip "$item")[1]} )
            local e=( $item )
            whichm "${(u@)is:|e}"
            continue
        }
        output="$(which -- "$item")" && ! [[ "$output" =~ '^\s*\w+: suffix aliased to' ]] && {
                test -e "/$output" && {
                    test -n "$whdeep_gen_mode" && {
                        [[ "$output" =~ "^\s*\Q$NIGHTDIR\E" ]] && cp "$output" ./autobin/
                        whdeep_gen_binaries+="$output"
                        continue
                    }
                    # output="# $output"
                    output=""
                    for binary in "${(@f)$(where $item)}" ; do
                        output+="# $(ll $binary)"$'\n'
                    done
                }
                ec $output
            }
    done
}
function wh() { whichm "$@" | btz }
function whh() {
    preEnhNames "$@"
    wwNight=y whdeep-words "$out[@]"
    wh "${(@)out}"
}
function whdeep-words() {
    out=()
    local input=("$@")

    local e=( '""' {0..10} "()" "{" "}" '"$@"' ':' '\:' aliased to noglob '\noglob' 'DEBUGME=d' '||' '&&' 'return' local false true "${(@f)$(enable)}" do done esac then elif else fi for case if while 'function' 'repeat' time until select coproc nocorrect foreach end '!' '[[' declare export float integer local readonly typeset '...' alias from import '$' ) 
    e+=( f v ) # usually false positives
    test -n "$wwNight" && e+=( run-on-each ruu proxychains4 )
    local line
    local i=()
    for line in "${(f@)$(whichm "$input[@]")}"
    do
        if ! [[ "$line" =~ '^\s*\\?((noglob)? : |m_doc )' ]] ; then
            IFS=$' \t\n\C-@'"'"'(){}"' eval 'i+=("$=line")'
        fi
    done
    i=( "${@:|e}" "${(@)i[2,-1]:|e}" )
    local word
    for word in "${(u@)i}"
    do
        test -e "/$word" || out+=$word
    done
}
function whdeep() {
    local oldwords=("$@")
    out=("$@")
    for i in {1..${wdN:-1000}}
    do
        # We currently repeatedly feed old words into whdeep-words which is not needed but it's fast enough so whatever
        whdeep-words "$out[@]"
        (( ${#out} == ${#oldwords} )) && break
        oldwords=("$out[@]")
    done
    ecdbg whdeep recursed $i times

    ec "&>/dev/null options=( ${(kv)options} )

alias m_doc=':'
"
    whichm "$out[@]"
}
function whdeep2script() {
    mdoc "$0 <function> [<script-name>]
Generates a standalone script that runs the given function." MAGIC
    
    local func="$1" script="${2:-$1_$(uuidpy).zsh}"
    serr rm -r ./autobin/ ./autodeps/
    local whdeep_gen_mode=y
    local whdeep_gen_binaries=()
    cp $pipables $nodables ./autodeps/
    {
        ec '#!/usr/bin/env zsh
export AUTO_WHDEEP_MODE=y
(( ${+commands[realpath]} )) || {
  echo You need "realpath" from coreutils installed.
  exit 1
}
export MYDIR="$(realpath "${0:h}")/"
PATH="${MYDIR}autobin/:$PATH"

### Automatically generated code starts
'$'\n'
        whdeep "$func"
        ec '### Automatically generated code ends'
        ec $'\n''test -n "$autowhdeepwarning" || {
echo "######"
echo This script has been automatically generated from my zsh files. It probably works, but there is a minute chance that some functions/aliases needed might be missing. You need to install the requisite binaries for this script to work. You also need an up-to-date zsh with support for re_match_pcre, though things may work without it if you are very lucky.'
        ec " echo Files at '$NIGHTDIR' can be found on my repo github.com/NightMachinary/.shells . They should be included in the folder 'autobin' near the generated script, but if not, just download them and add to PATH manually. Please note that these scripts' dependencies have NOT been included. It has been my hope that they don't have any or what they require is obvious through the error messages. I have included pip and npm packages that I use globally in the folder 'autodeps', and installing all of them might make things easier."
        ec "echo 'Needed binaries (this list might not be exhaustive, and some of these might actually NOT be needed):
coreutils
moreutils
findutils"
        arrN "$whdeep_gen_binaries[@]"
        ec \'
        ec ' echo Set the environment variable \"autowhdeepwarning\" to \"no\" to avoid seeing this message. ; echo "######" ; echo }'$'\n'
        ec "$func "'"$@"'
    } > $script
local zipdest="${script:r}.zip"
serr rm "$zipdest"
    zip -r $zipdest $script ./autobin ./autodeps
    pbadd "$zipdest"
}
function cee() {
    cat `which "$1"`
}
function ceer() {
    geval "${@:2} $(which "$1")"
}
mn() {
    man "$@" || lesh "$@"
}
