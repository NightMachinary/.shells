function ntl() {
    ensure-array ntsearch_rg_opts

    local opts=()
    local i
    for i in org md txt zsh ; do
        opts+=( --iglob "*.${i}" )
    done

    ntsearch_injector="unseal-get2note" ntsearch_glob='' ntsearch_rg_opts=("$opts[@]" "$ntsearch_rg_opts[@]") ntl-rg "$@"
}
noglobfn ntl
aliasfnq-ng ntl. nightNotes=. ntsearch_glob='' ntsearch-lines # ntsearch_glob=$textglob
@opts-setprefix ntl. ntsearch-lines
aliasfn-ng see ntl.
##
aliasfnq-ng sees nightNotes=. ntsearch_glob='' ntl-rg # ntsearch_glob=$textglob
aliasfnq-ng sees-fzf nightNotes=. ntsearch_glob='' ntl-fzf # ntsearch_glob=$textglob
aliasfnq-ng sees-fzfq nightNotes=. ntsearch_glob='' ntl-fzfq # ntsearch_glob=$textglob
##
# still does not see binaries
aliasfn-ng seesall ntsearch_rg_opts=(--no-ignore --hidden) nightNotes=. ntsearch_glob='' ntl-rg
aliasfn-ng seesall-fzf ntsearch_rg_opts=(--no-ignore --hidden) nightNotes=. ntsearch_glob='' ntl-fzf
aliasfn-ng seesall-fzfq ntsearch_rg_opts=(--no-ignore --hidden) nightNotes=. ntsearch_glob='' ntl-fzfq
##
function seev() {
    init-vfiles
    ntLines=y nightNotes="/" ntsearch_additional_paths=($vfiles[@]) ntsearch_glob='' ntl-rg "$@" # ntsearch_glob=$textglob
}
noglobfn seev
##
aliasfn-ng agsi nightNotes="$NIGHTDIR" ntsearch_additional_paths=(~/.zshenv ~/.zshrc ~/.shared.sh ~/.localScripts ~/.glances ~/.vimrc ~/.ideavimrc ~/.tmux.conf ~/.privateBTT.sh ~/.privateShell ~/.privateStartup.sh ~/test_nonexistent) ntsearch_glob='' ntl-rg # ntsearch_glob=$textglob
function agfi1() {
    ##
    # a bit faster than the ugrep mode, possibly because i0o0 wastes two invocations of prefixer
    # note that this streams the results while the ugrep mode waits for the results to finish, so this appears faster than it really is
    ##
    local f="$1"
    ntsearch_query_fzf="'$f '() | 'alias | 'alifn " agsi  # match functions or aliases
}
function agfi {
    ## PERF:
    # `FZF_DEFAULT_OPTS+=' -1'`
    # `redo2 100 time2 silent agfi dbgserr`
    # `redo2 100 time2 silent agfi1 dbgserr`
    # agfi1 is ~9ms faster
    ##
    local f="$1" prefix_mode="${agfi_p}"
    # f="$(ec "$f" | sdlit . '\.')" # not worth the perf hit, though I haven't benchmarked

    local -x FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height 50% --select-1"
    local q
    ##
    # local word_break='\W'
    # using '\b' doesn't work with names such as 'ntl.', but using '\W' breaks ugrep:
    # https://github.com/Genivia/ugrep/issues/114
    # best is to just use 'ntl' instead of 'ntl.', as the dotted versions are matched as well
    local word_break='\b'
    ##
    if ! isI || test -n "$prefix_mode" ; then
        q=":\s*${word_break}function\s+${f}|:\s*${word_break}${f}[^:]*\s*\(\)|:\s*alias[^:=]*\s*${word_break}$f|:\s*alifn[^:=]*\s*${word_break}$f "
    else
        q=":\s*${word_break}function\s+${f}${word_break}|:\s*${word_break}${f}${word_break}\s*\(\)|:\s*alias[^:=]*\s*${word_break}$f${word_break}|:\s*alifn[^:=]*\s*${word_break}$f${word_break} "
    fi

    isDbg && ec-copy "$q"
    local ntsearch_lines_nw=y ntsearch_lines_fe=y fzp_ug=y ntsearch_lines_nnp=y ntsearch_query_fzf="$q"
    if isI ; then
        # We need to run this without piping in the interactive case, or else jumping to editor will break
        agsi
    else
        agsi | sd '\n' '\n\n' # improves readability
    fi
}
noglobfn agfi
##
function ntt() {
    local query="$(fzp_ug=ni fz-createquery "$@")"

    ntsearch_query_fzf="$query" ntl
}
###
function rem-fz() {
    local query_pre="$rem_fz_q"
    local query="$(fzp_ug=ni fz-createquery "$@")"

    local fz_opts=( "$fz_opts[@]" --no-sort ) # no-sort is needed to get the items sorted according to their actual date

    local nightNotes="$remindayDir"

    local now=("${(s./.)$(datej)}")
    local cyear="$now[1]"
    local cmonth="$now[2]"
    local cday="$now[3]"
    local ntsearch_additional_paths=( "$remindayBakDir/$cyear/$cmonth/$cday"^*.zsh(N.) )

    ensure-array ntsearch_rg_opts
    ntsearch_glob='' ntsearch_rg_opts=("$ntsearch_rg_opts[@]" --iglob '!*.zsh') ntl-fzf "$query_pre $query"
}
aliasfn ntrem rem-fz
aliasfn rem rem-fz
function remd() {
    ## tests:
    # `fnrep datej "ec 1399/12/03" remd`
    # `fnswap isI false fnrep datej "ec 1399/12/03" remd`
    # `fnswap isI false remd`
    # `FORCE_NONINTERACTIVE=y remd mid`
    ##
    local query="$(fzp_ug=ni fz-createquery "$@")"

    local ntsearch_lines_nnp=y
    
    local now=("${(s./.)$(datej)}")
    local cyear="$now[1]"
    local cmonth="$now[2]"
    local cday="$now[3]"

    if (( cmonth == 12 )) ; then
        local nextYear=$((cyear+1))

        @opts q "$(fzp_ug=ni fz-createquery "$cyear/$cmonth" "|" "$nextYear/01")" @ rem-fz $query
    else
        typeset -Z2 nextMonth
        nextMonth=$((cmonth+1))

        @opts q "$(fzp_ug=ni fz-createquery "$cyear/$cmonth" "|" "$cyear/$nextMonth")" @ rem-fz $query
    fi
}
###
function ntimg() {
    innt fdrp --full-path --extension png --extension jpg --extension svg --extension jpeg "$*" | fz | inargsf imgcat
}
aliasfn nti ntimg
###
function rgf_() {
    # @todo shortcuts to navigate multiple lines at a time (to skip the context lines) will help

    # local opts=( --delimiter ':|-|\x00' --with-nth 1,3..)
    local opts=( )
    RG_PREFIX="$functions[rgbase] -C 4 --null --line-number --no-heading -e"
    local INITIAL_QUERY=( "$@" )

    FZF_SIMPLE_PREVIEW='cat {f}' \
    FZF_DEFAULT_COMMAND="$RG_PREFIX $(gq ${INITIAL_QUERY:-.})" \
        fz-empty --reverse --bind "change:reload:$RG_PREFIX {q} || true" ${opts[@]}  --ansi --disabled --query "$INITIAL_QUERY" --expect=alt-enter | {
        read -d $'\n' -r acceptor
        out="$(cat)"
        print -r -- "$out"
        out=("${(@f)out}")
    }
}
# @bug `--` won't fit this pattern, though it shouldn't be included in your selections anyways?
aliasfnq rgf @opts engine rgf_ pattern '(.*)\0(\d+)[:-](.*)' @ ntl.
aliasfn seerg rgf
aliasfn rgsee rgf
aliasfn ffrg rgf
##
function emcnt() {
    emc-gateway -e "(night/search-notes)"
}
function vnt() {
    outFiles=()
    { ntsearch "$@" > /dev/null } || return 1
    reval "${veditor[@]}" "$outFiles[@]"
}
##
function ntl-rg() {
    ntsearch_query_rg="$*" ntsearch-lines
}
function ntl-fzf() {
    ntsearch_query_fzf="$*" ntsearch-lines
}
function ntl-fzfq() {
    local query="$(fzp_ug=ni fz-createquery "$@")"

    ntsearch_query_fzf="$query" ntsearch-lines
}
##
function ntsearch-whole() {
    @opts engine ntsearch pattern '(.*)\n' @ ntsearch-lines
}
alias nts='\noglob ntsearch-whole'

function ntsearch-whole-rg() {
    : '@untested @experimental'

    ntsearch_rg_opts=( --multiline --multiline-dotall ) ntsearch_query_rg="$*" ntsearch-lines
}
##
function ntsearch-lines-engine() {
    ntLines=y ntsearch "$@"
}
alias snw='ntsearch_lines_nw=y '
function ntsearch-lines() {
    : "Remember that ntsearch_ uses eval-memoi"
    : "Note that ntsearch and ntsearch_ use their input as a glob to filter files"
    : "Use alt-enter to jump straight into editing the files! Multiple selection is possible!"

    : "The engine should return output in outFiles."
    local engine=("${(@)ntsearch_lines_engine:-ntsearch-lines-engine}") pattern="${ntsearch_lines_pattern}" ni_noprocess="${ntsearch_lines_nnp}" no_wait="${ntsearch_lines_nw:-y}" force_editor="${ntsearch_lines_fe}"
    if isSSH || [[ "{$no_wait:l}" == (n|no) ]] ; then
        no_wait=''
    fi
    test -z "$pattern" && pattern='^([^:]*):([^:]*):(.*)'

    outFiles=() out=() # out and outFiles contain almost the same data when ntLines=y
    # outFiles is no longer used by anything except `vnt`?
    ntsearch_lines_pattern="$pattern" reval "$engine[@]" "$@" > /dev/null  || return 88 # Beware forking here! We need the global vars out and acceptor

    if ! isI && test -n "$ni_noprocess" ; then
        ec "${(@F)out}"
        return 0
    fi

    ntsearch-postprocess
}
##
function ntsearch-postprocess-h1 {
    local out="$3"
    # cp "$out" ~/tmp/a.txt @TRET
    out="$(cat "$out")" @TRET
    nightNotes="$1" pattern="$2" out="$out" force_editor=y no_wait=y ntsearch-postprocess
}
function ntsearch-postprocess {
    # @input nightNotes out pattern acceptor ntsearch_injector force_editor no_wait EDITOR
    ##
    local i files=() linenumbers=() lines=() file
    for i in "${out[@]}" ; do
        unset match
        # dvar i
        if [[ "$i" =~ "$pattern" ]] ; then
            # dvar match
            file="$match[1]"
            test -e "$file" || {
                # file="$(<<<$file rmprefix "$nightNotes")"
                file="$nightNotes/$file"
                file="$(grealpath "$file")" # needed for opening files in the editor
            }
            if ! test -e "$file" ; then
                if true || test -z "$ntsearch_injector" ; then
                    ecerr "$0: $(gq "$file") does not exist."
                else
                    color 100 200 200 "$0: File does not exist, probably a selection from the injector."$'\n\n' >&2
                    dvar file
                fi
            else
                files+="$file"
                linenumbers+="${match[2]:-1}"
                lines+="$match[3]"
                continue
            fi
        else
            if true || test -z "$ntsearch_injector" ; then
                ecerr "$0: ntsearch has returned illegible data."
            else
                color 100 200 200 "$0: illegible data, probably a selection from the injector."$'\n\n' >&2
            fi
            dvar i
        fi
        ## Old way: Just returning everything
        # ec "$(<<<"${(F)out}" rmprefix "$nightNotes")"
        # return 1
        ## New way: faking data
        files+="~/tmp/madeup.txt"
        linenumbers+="1"
        lines+="$i"
    done

    # re dvar out files linenumbers lines

    if test -z "$force_editor" && [[ "$acceptor" == '' ]] ; then
        ecdbg "$0: Outputting selections ..."
        local sel="${(F)lines}"
        <<<"${sel}" urls-copy
        return 0
    else
        ecdbg "$0: Opening editor ..."
        if [[ "$EDITOR" =~ '^emacs' ]] ; then
            local opts=()
            if test -n "$no_wait" ; then
                opts+='--no-wait'
                # --no-wait will open stuff in the active frame, instead of opening a new frame
            fi
            local cmd='(progn '
            for i in {1..$#files} ; do
                # (forward-char $col)
                ##
                if (( $#files > 1 )) ; then
                    cmd+="(tab-bar-new-tab) "
                    if (( i == 1 )) ; then
                        cmd+="(tab-bar-close-other-tabs) " # @weirdFeature
                    fi
                fi
                cmd+="(find-file \"${files[$i]}\") (goto-line ${linenumbers[$i]}) "
                ##
                cmd+='(recenter) '
            done
            # lower than this 1.5 delay will not work. More delay might be necessary for edge cases.
            # The first time we use this in a zsh session, the highlight sometimes does not work. Idk why.
            cmd+="(run-at-time 0.15 nil #'+nav-flash-blink-cursor-h) "
            cmd+=')'

            if test -n "$no_wait" ; then
                revaldbg emc-eval "$cmd" & # this decreases the latency but can sometimes open emacs too soon (before it has jumped to the desired location)
                emc-focus
            else
                revaldbg emacsclient "${opts[@]}" -a '' -t -e "$cmd"
            fi

        else
            ##
            # should work with both emacs and vim
            # VSCode: code --goto <file:line[:character]> Open a file at the path on the specified line and character position.--goto file:line[:col]
            # I don't know about opening multiple files on vscode (we can always run the command multiple times)
            ##
            # [[id:dc56c812-14ba-4f42-8484-18456dc9132b][vim/tabs.org]]
            # EDITOR='nvim -p'
            ##
            local cmd="$EDITOR "
            for i in {1..$#files} ; do
                cmd+="+${linenumbers[$i]} $(gq "${files[$i]}") "
            done
            eval "$cmd"
        fi
    fi
}
##
function ntsearch() {
    : "GLOBAL: out outFiles"

    out=''
    outFiles=()
    local nightNotes="$nightNotes"
    export nightNotes="$(realpath --canonicalize-existing "$nightNotes")" || { # we need to export this because the preview shell accesses it.
        ecerr "$0: nightNotes dir does not exist"
        return 1
    }

    local fzp_ug="$fzp_ug"
    if ! isI ; then
        # @surprise
        fzp_ug=y
        # non-interactive fzf returns bad output that is ugly unprocessed, and can't be processed by our normal code
    fi

    ntsearch_ "$@" > /dev/null || {
        ecerr "$0: ntsearch_ failed $?."
        unset out
        return 1
    } # don't fork here. Receiving globals vars out and acceptor.

    if isI || test -z "$fzp_ug" ; then
        # fzp_ug doesn't output zero in non-interactive usage (because fzf is not invoked), so we don't need to break these.
        out=( "${(@0)out}" )
        out=( "${(@)out[1,-2]}" ) # remove empty last element that \0 causes
    else
        out=( "${(@f)out}" )
    fi

    if test -z "$ntLines" ; then
        ensure isI @MRET
        local i
        for i in "$out[@]"
        do
            outFiles+="$nightNotes/$(<<<"$i" head -n 1)"
        done
        ec "${(@F)out}"
    fi
}
function ntsearch_() {
    : "See vnt, ntsearch-lines"
    : "INPUT: ntsearch_lines_pattern, ntsearch_query_rg, ntsearch_query_fzf, ntsearch_additional_paths, nightNotes, ntLines , GLOBAL: acceptor out"

    acceptor=''
    out=''
    bella_zsh_disable1=y

    local ntLines="$ntLines"

    local additional_paths=(${(@)ntsearch_additional_paths})
    # Checking for existence introduces noticeable delay, but has little benefit. So we don't.
    # local additional_paths=("${(@f)$(<<<${(F)ntsearch_additional_paths} filter test -e)}")

    dvar additional_paths
    local files
    # files=( "${(@f)$(fd -e md -e txt -e org --full-path ${pattern} $nightNotes )}" )
    files=(${additional_paths[@]})
    [[ "$nightNotes" != '/' ]] && {
        if test -n "$ntsearch_glob" ; then
            local glob="*$ntsearch_glob"
            files+=($nightNotes/**/${~glob}) # `/` means we are only interested in additional_paths, but since the machinary relies on nightNotes existing, we use `/`.
        else
            files+="$nightNotes"
        fi
    }
    (( $#files == 0 )) && {
        ecerr "$0: No valid paths supplied. Aborting."
        return 1
    }
    local query_rg="${ntsearch_query_rg:-\S+}" # removes empty lines
    local query="$ntsearch_query_fzf"
    # test -z "$query" || query="'$query"
    # local pattern="."

    local fzopts=()
    local previewcode="$FZF_SIMPLE_PREVIEW"
    local preview_header_lines
    local hidden
    if test -z "$ntLines" ; then
        preview_header_lines=2
        hidden='hidden' # preview is useless as ntsearch-whole does not track the line number info needed to scroll to the right place

        if test -z "$fzp_ug" ; then
            fzopts+='--read0'
        else
            ecerr "$0: ugrep does not support read0"
            return 1
        fi
        previewcode="cat {f}"
    else
        preview_header_lines=3
        hidden='nohidden'

        if test -z "$fzp_ug" ; then
            fzopts+=(--read0 --delimiter : --with-nth '1,3..' --nth '..') # nth only works on with-nth fields
        else
            fzopts+=(--delimiter : --nth '1,3..')
        fi
        ###
        # https://github.com/junegunn/fzf/issues/2373 preview header
        # remove `:+{2}-/2` from preview-window and use mode=0 to revert to the previous behavior
        ##
        local rtl=''
        # rtl='| rtl_reshaper.dash' # very bad perf for large files
        # adding ` | rtl_reshaper.dash` works fine if RTL text is not colored, it seems. It's best if ntom does the reshaping itself ...
        ##
        previewcode="ntom {1} {2} {s3..} $(gq $nightNotes) 1 $rtl || printf -- \"\n\n%s \" {}"
        ##
        # previewcode="cat $(gq $nightNotes)/{1} || printf -- error5"
        ###
    fi


    fzopts+=(--bind 'ctrl-\:execute-silent(brishzq.zsh ntsearch-postprocess-h1 '"$(gq "$nightNotes") $(gq "$ntsearch_lines_pattern")"' {f})') # '{}' puts the current line itself, '{f}' puts a file containing it


    ##
    # we no longer need caching, it's fast enough
    # memoi_expire=$((3600*24)) memoi_key="${files[*]}:${ntLines}:$nightNotes:$query_rg" eval-memoi

    ntsearch_fd | fz_empty=y fzp_dni=truncate fzp --preview-window "right,50%,wrap,${hidden},+{2}-/2,~${preview_header_lines}" --preview "$previewcode[*]" --ansi ${fzopts[@]} --print0 --expect=alt-enter "$query" | {   # right:hidden to hide preview
        unset acceptor
        if isI ; then
            read -d $'\0' -r acceptor
        fi
        out="$(cat)"
        ec "$out"
    } || {
        local ret=$? s="${(j.|.)pipestatus[@]}"
        ecerr "$0: failed last statement with: $s"
        return $ret
    }
    # | gawk 'BEGIN { RS = "\0" ; ORS = RS  } ;  NF' # to remove empty lines (I don't know why I commented this, or if it actually works. But I now use rg itself to filter empty lines out.

}
function ntsearch_fd_h() {
    print -nr -- "${(@pj.\0.)files}" \
        | gxargs -0 rg --no-binary --smart-case --engine auto --no-messages --with-filename --line-number --sort path $ntsearch_rg_opts[@] "$@" -- "$query_rg" \
        | prefixer --skip-empty -r "$nightNotes" -i $'\n' -o "$osep"
    # no-messages suppresses IO errors
    # xargs is needed to avoid argument list too long error

}
function ntsearch_fd() {
    : "INPUT VARS: ntsearch_injector ntsearch_rg_opts files ntLines nightNotes query_rg"

    local osep='\x00'
    if test -n "$fzp_ug" ; then
        osep=$'\n'
    fi
    if test -n "$ntLines" ; then
        {
           ntsearch_fd_h
        }
        if test -n "$ntsearch_injector[*]" ; then
            if test -n "$fzp_ug" ; then
                if ! isBrish ; then
                    ecgray "$0: ntsearch_injectors are not yet supported in ugrep mode, as they output NUL separated data. (NOT aborting.)"
                fi
            else
                # --null-data  bothh reads and write 0: `arr0 1 2 3 | rg --null-data -e 2 | cat -vte`
                reval "$ntsearch_injector[@]" | command rg --null-data --smart-case --engine auto --no-messages $ntsearch_rg_opts[@] -- "$query_rg"
            fi
        fi
        return 0 # rg exits nonzero if some of its paths don't exist, so we need to explicitly ignore it.
    else
        ##
        ntsearch_fd_h --files-with-matches | ntsearch_outputter.go "$nightNotes"
        ##
        # local first='y' file content files_all=()
        # files_all=("${(@0)$(ntsearch_fd_h -l)}") @RET
        # for file in "$files_all[@]"
        # do
        #     # dvar file
        #     test -n "$first" || {
        #             print -n $'\0'
        #     }
        #     first=''
        #     content="$(< "$nightNotes/$file")"
        #     color 30 90 255 $file$'\n'
        #     ec $content
        # done
        ##
    fi
}
##
function nt-lucene() {
    local q="$*" 
    # @globalInputs ntLines
    ## https://lucene.apache.org/core/2_9_4/queryparsersyntax.html
    # '+mustInclude'
    # 'wildcard*'
    # 'this is or'
    # 'me AND you' 'me && you'
    # '(jakarta OR apache) AND website'
    # '"grouped words"'
    ##
    
    local files opts=()
    
    # files=("$nightNotes"/**/${~noteglob})
    # files=("$nightNotes"/**/${~textglob})

    files=("${nightNotes%%/}/**/*.{${(j.,.)text_formats}}")
    # glob syntax: https://docs.oracle.com/javase/8/docs/api/java/nio/file/FileSystem.html#getPathMatcher-java.lang.String-
    
    if ! bool "$ntLines" ; then
        opts+=( --no-split )
    fi
    revaldbg lmgrep '--case-sensitive?' false --hyperlink "$opts[@]" -q "$q" "$files[@]"
}
alias ntc='\noglob nt-lucene'

function nt-lucene. {
    nightNotes="$PWD" nt-lucene "$@"
}
##
