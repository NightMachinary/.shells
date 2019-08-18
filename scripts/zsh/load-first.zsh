### Initiate the Darkness
export NIGHTDIR="${0:h:h}/" # echo "_: $_ 0: $0 bs: $BASH_SOURCE"
source-basic() source "$NIGHTDIR"/zsh/basic/"$*".zsh
source-basic basic
# malice is the alias module. :D
re source-basic cached conditions crossplatform args colors debug text-manipulation ssh malice enhancers redirections
run-on-each source "$NIGHTDIR"/zsh/basic/auto-load/**/*(.)
[[ "$(pwd)" != *borg* ]] || silence eval 'export jufile=(*)' # For use with the Julia module.
