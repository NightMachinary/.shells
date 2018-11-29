alias ai="sudo apt install"
alias au="sudo apt upgrade"
alias auu="sudo apt update"
alias ncs="sudo nextcloud.occ files:scan --all"
alias h="history|grep"
alias re='run-on-each'
alias sbash='source ~/scripts/bash/load-others.bash'
alias szsh='source ~/scripts/zsh/load-others.zsh'
alias yic='youtube-dl --ignore-config'
alias reeb='run-on-each rename-ebook'
alias aa='aria2c --seed-time=0 -Z'
alias anki='/Applications/Anki.app/Contents/MacOS/Anki -b /Base/_GDrive/Anki'
alias pc='pbcopy'
alias ch='cht.sh'
alias powerdecay="sudo powermetrics -i 1000 --poweravg 1 | grep 'Average cumulatively decayed power score' -A 20"
alias bu='brew upgrade'
alias bcu='brew cask upgrade'
alias ynow='y -f best'
alias ddg='ddgr --unsafe -n 6'
alias dg='ddg --noprompt'
alias ggg='googler -n 6'
alias gg='ggg --noprompt'
alias t.hv='tmux new-session \; split-window -h \; split-window -v \; attach'
alias p='sdc $(pbpaste)'
alias lynx="lynx -cfg=~/.lynx.cfg  --accept_all_cookies"
alias rsp='rsync --human-readable --xattrs --times --delete-after --ignore-errors --force-delete --partial-dir=.rsync-partial  --info=progress2 -r'
alias rspm='rsp --crtimes'
alias rspb='rsp --backup --backup-dir=.rsync-backup'
alias rspbm='rspb --crtimes'
alias fsayd='fsay Darkness is Paramount'
case "$(uname)" in
    Darwin)
        alias ggrep='ggrep  --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
        ;;
    Linux)
        alias ggrep='grep  --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
        ;;
esac

