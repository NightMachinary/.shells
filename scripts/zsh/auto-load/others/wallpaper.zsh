function wallpaper-set-darwin() {
    local f
    f="$(realpath "$1")" || return $?

    # osascript -e 'tell application "Finder" to set desktop picture to POSIX file "'$f'"' || return $?

    mcli wallpaper "$f" || return $?

    # Try `killall Dock` if this didn't work.
}
##
function wallpaper-auto-bing() {
    pushf ~/Pictures/wallpapers/bing
    {
        local dest="$(uuidm).jpg"
        reval-ec aa "$(bing-wallpaper-get)" -o "$dest"
        reval-ec wallpaper-set-darwin "$(last-created)" || notif "$0: setting wallpaper returned $?"
    } always { popf }
}
##
