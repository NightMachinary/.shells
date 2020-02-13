alias t.hv='tmux new-session \; split-window -h \; split-window -v \; attach'
ivy() {
    tmux new-session -d 'zsh'
    tmux send-keys "mu "
    tmux split-window -h  'zsh'
    tmux send-keys "luna
"
    # tmux split-window -v 'ipython; zsh'
    tmux split-window -v 'salice.py'
    tmux select-pane -t 0
    comment order matters. Select a pane before attaching.
    comment '-2            Force tmux to assume the terminal supports 256 colours.'
    tmux -2 attach-session -d
}
