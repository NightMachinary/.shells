psource "$HOME/.privateShell"
[ -e ~/.localScripts ] && re psource ~/.localScripts/**/*.zsh || :
if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi
