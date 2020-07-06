fd_default=( --hidden --no-ignore )
h2ed='html2epub-pandoc'
export cellar=~/cellar
export music_dir="$HOME/my-music"
to_dirtouch=y
export logdir="$HOME/logs"
PRUNE_SONGD_DAYS="+120"
export deleteus=~/.deleteus
export codedir="$HOME/code"
##
export nightNotes="$cellar/notes/"
export nightJournal="$nightNotes/journal/j0/"
note_formats=( txt md org )
noteglob="*.(${(j.|.)note_formats})(D)"
##
audio_formats=(mp3 m4a m4b ogg flac ogm opus wav)
audioglob="*.(${(j.|.)audio_formats})(D)"
video_formats=(ape avi flv mp4 mkv mov mpeg mpg rm webm)
media_formats=( ${audio_formats[@]} ${video_formats[@]} )
code_formats=( py jl scala sc kt kotlin java clj cljs rkt js rs toml zsh dash bash sh ml php lua glsl frag )
config_formats=( ini json cson toml conf )
text_formats=( $note_formats[@] $code_formats[@] $config_formats[@] )
##
if isDarwin ; then
    veditor=(code-insiders -r)
    cookiesFiles="${HOME}/Library/Application Support/Google/Chrome/Default/Cookies"
else
    test -e ~/.SpaceVim && veditor=(svi -p) || veditor=(vim -p) # doc '-o opens in split view, -p in tabs. Use gt, gT, <num>gt to navigate tabs.'
fi

