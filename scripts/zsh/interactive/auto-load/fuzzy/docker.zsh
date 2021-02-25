# Get more commands from https://github.com/mnowotnik/extra-fzf-completions/blob/master/zsh/docker-fzf-completion.zsh
###
# FZF_DOCKER_PS_FORMAT="table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Ports}}"
# FZF_DOCKER_PS_FORMAT="table {{.ID}}     {{.Names}}     {{.Image}}     {{.Ports}}     {{.Status}}     {{.RunningFor}}"
FZF_DOCKER_PS_FORMAT="table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}\t{{.RunningFor}}"
# FZF_DOCKER_PS_START_FORMAT="table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"

function ffdocker-ps() {
    local query="$(fz-createquery "$@")"
    fz --header-lines=1 --with-nth '2..' --query "$query" <<<"$(docker ps --all --format "${FZF_DOCKER_PS_FORMAT}")" | awk '{print $1}'
}

function ffdocker-gen() {
    typeset -a ffdocker_gen_post_cmd
    local cmd=("${(@)ffdocker_gen_cmd:?}") post_cmd=("${(@)ffdocker_gen_post_cmd}")
    local ps i
    ps=("${(@f)$(ffdocker-ps "$@")}") || return 1
    for i in "$ps[@]" ; do
        rgeval docker "$cmd[@]" "$i" "$post_cmd[@]"
    done
}
aliasfn ffdocker-attach @opts cmd [ exec -it ] post_cmd bash @ ffdocker-gen
aliasfn ffdocker-start @opts cmd start @ ffdocker-gen
aliasfn ffdocker-stop @opts cmd stop @ ffdocker-gen
aliasfn ffdocker-rm @opts cmd rm @ ffdocker-gen
