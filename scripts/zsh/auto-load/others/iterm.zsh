##
function iterm-boot() {
    # Alt: `lnrp iterm_focus.py ~/Library/Application\ Support/iTerm2/Scripts/AutoLaunch/` uses iterm's own python which doesn't have our Brish
    tmuxnewsh2 iterm_focus ITERM2_COOKIE=$(osascript -e 'tell application "iTerm2" to request cookie') reval-notifexit iterm_focus.py
}
##
it2prof() { echo -e "\033]50;SetProfile=$1\a" ; } # Change iterm2 profile. Usage it2prof ProfileName (case sensitive)
##
function iterm-session-active() {
    : "Needs iterm_focus.py running. Currently gets last active session, i.e., if you switch to Chrome, the active session won't be set to null. We can probably solve this, as there is a TERMINAL_WINDOW_RESIGNED_KEY event, but the current behavior seems better."
    # : "Doesn't work with tmux. iTerm's native tmux integration is also very invasive and not suitable for us. Setting ITERM_SESSION_ID manually by ourselves can solve this problem somewhat. It would work fine for ivy, but detaching and reattaching is hard to get right for it if at all."
    # Alt for linux: See focus events http://invisible-island.net/xterm/ctlseqs/ctlseqs.html:
    # These need iTerm to immediately send the focus events when enabled, not waiting for a focus change. I tested it with `unset hi ; echo -ne '\e[?1004h\e[?1004l'; read -r -k 3 -t 0.5 hi ; typeset -p hi`; `hi` remained unset.
    # Alt for linux: xdotool https://unix.stackexchange.com/questions/480052/how-do-i-detect-whether-my-terminal-has-focus-in-the-gui-from-a-shell-script

    redis-cli --raw get iterm_active_session
}

function iterm-session-my() {
    if [[ "$ITERM_SESSION_ID" =~ '[^:]*:(.*)' ]] ; then
        ec "$match[1]"
    else
        return 1
    fi
}

function iterm-session-is-active() {
    [[ "$(iterm-session-active)" == "$(iterm-session-my)" ]]
}

function iterm-focus-get() {
    redis-cli --raw get iterm_focus
}

function iterm-focus-is() {
    [[ "$(iterm-focus-get)" == TERMINAL_WINDOW_BECAME_KEY ]]
}
