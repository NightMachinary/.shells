function lunar() {
    deluna ${deluna} & # timeout of deluna
    lo_s=$((60*${lo_min:-45})) lo_noinit=y lo_p=${lo_p:-~/tmp/.luna} loop "$@"
}
luna() {
    lunar pmset displaysleepnow
}
##
lunas() {
    lunar bell-many
}
bell-many() {
    setopt localtraps
    # So I don't understand these all that well, but here is my guess:
    trap "" INT # disables INT handling in this function, so we don't quit by INT
    (redo bell-luna 25) # this is a new process so it has its own signal handling and so does quit on INT
    # 25  1:23.87 total
    # each is about 3.5s

    ecdate "Luna iterated."
}
bell-avarice() {
    # say "disquiet creatures of avarice have risen yet again ..."
    @opts v 70 @ hearinvisible "$(rndarr $NIGHTDIR/resources/luna/$~audioglob)"
}
bell-toy() {
    # say "disquiet creatures of avarice have risen yet again ..."
    @opts v 70 @ hearinvisible "$(rndarr $GREENCASE_DIR/toystory2/**/$~audioglob)"
}
function greencase_audio_init() {
    { test -z "$greencase_audio_init" || test -n "$*" } && {
        greencase_audio=( $GREENCASE_DIR/**/$~audioglob )
    }
}
bell-greencase() {
    ##
    # @todo0 this doesn't result in a constantish duration, so we'll additional code to check the duration in a while loop in bell-many
    #
    ## Perf:
    # The delay is in the files themselves, these below have same time and both sound delayed:
    # time (@opts v 70 @ hearinvisible '/Users/evar/Base/Music/greencase/PC Computer - Portal 2 - Turret/turretlaunched05.wav')
    # time (hearinvisible '/Users/evar/Base/Music/greencase/PC Computer - Portal 2 - Turret/turretlaunched05.wav')
    ##
    greencase_audio_init
    reval-ec @opts v 70 @ hearinvisible "$(rndarr $greencase_audio[@])"
}
# aliasfn bell-luna bell-avarice
aliasfn bell-luna bell-greencase
##
aliasfn lunaquit loop-startover ~/tmp/.luna
aliasfn lq lunaquit
function deluna() {
    local nonce
    nonce="$(oneinstance-setup $0)" || return 1
    local timeout="${1:-150}" # 150 is good for PC work, but 800 might be better for reading, as the screen dims in 10 minutes
    ec "deluna (nonce: $nonce) started with timeout $timeout"
    while oneinstance $0 $nonce
    do
        (( $(getidle-darwin) >= $timeout || $(getlastunlock-darwin) <= 80 )) && {
            edPre=$'\n' ecdate "$(color 255 100 255 'Deluna committed homicide!')"
            lunaquit " via deluna"
            # { isDbg && sleep 1 } || sleep 30
        }
        sleep 30 # to avoid cpu usage
    done
    ec deluna exited "(nonce: $nonce)"
}
function nnl() {
    mdoc "Not Now Luna!" MAGIC
    local started="$(date +"%s")"
    local vol="$(get-volume)"
    local timeout=150
    isDbg && timeout=5

    set-volume 0

    # No need for this much force:
    # while (( ($(date +"%s") - $started) <= $timeout ))
    # do
    #     set-volume 0
    # done

    sleep $timeout

    set-volume "$vol"
}
##
bellj_socket=~/.sockets/bellj
bellj_say="Jingle bells, jingle bells,
Jingle all the way.
Oh! what fun it is to ride
In a one-horse open sleigh."
function bell-jingles() {
    fsay $bellj_say
}
function bell-ReichPhase() {
    @opts v 130 @ hearinvisible $NIGHTDIR/resources/audio/ReichPhase.wav
}
function bellj1() {
    local bell="${1:-bell-ReichPhase}"
    lo_sig2cancel=y lo_s=3 lo_p=${lo_p:-$bellj_socket} loop "$bell" #bell-helicopter
}
function bell-helicopter() {
    local duration="${1:-3}"

    ot-play-helicopter # it'd be better if this supported a duration itself, as ot-stop will stop everything.
    sleep "$duration"
    ot-stop
}
aliasfn okj1 retry_sleep=0.1 retry-limited 500 loop-startover $bellj_socket
aliasfn bellj2 ot-play-helicopter
aliasfn okj2 ot-stop
aliasfn bellj-toy bellj1 bell-toy
aliasfn bellj-gc bellj1 bell-greencase
# aliasfn bellj bellj2
# aliasfn okj okj2
aliasfn bellj bellj-gc
aliasfn okj okj1
