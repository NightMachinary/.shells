colorfg() printf "\x1b[38;2;${1:-0};${2:-0};${3:-0}m"
colorbg() printf "\x1b[48;2;${1:-0};${2:-0};${3:-0}m"
colorb() {
    co_f=colorbg color "$@"
}
color() {
    [[ "$1" =~ '^\d+$' ]] &&
        {
            "${co_f:-colorfg}" "$@"
            shift 2
        } || printf %s "$fg[$1]"
    print -nr -- "$(in-or-args "${@:2}")"
    resetcolor
    echo
}
resetcolor() {
    comment This var is seemingly coming from a plugin or sth
    printf %s "$reset_color"
}
helloworld() {
    colorbg 0 0 255;colorfg 0 255; ec HELLO "$(colorfg 255 100)"BRAVE"$(colorfg 0 255)" $(colorbg 100 0 255)NEW$(colorbg 0 0 255) WORLD\!;resetcolor
}
printcolors() {
    printf "\x1b[${bg};2;${red};${green};${blue}m\n"
    helloworld
    comment awk 'BEGIN{
    s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
    for (colnum = 0; colnum<77; colnum++) {
        r = 255-(colnum*255/76);
        g = (colnum*510/76);
        b = (colnum*255/76);
        if (g>255) g = 510-g;
        printf "\033[48;2;%d;%d;%dm", r,g,b;
        printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
        printf "%s\033[0m", substr(s,colnum+1,1);
    }
    printf "\n";
}'
    ec 'https://github.com/johan/zsh/blob/master/Functions/Misc/colors
# Text color codes:
  30 black                  40 bg-black
  31 red                    41 bg-red
  32 green                  42 bg-green
  33 yellow                 43 bg-yellow
  34 blue                   44 bg-blue
  35 magenta                45 bg-magenta
  36 cyan                   46 bg-cyan
  37 white                  47 bg-white
# 38 iso-8316-6           # 48 bg-iso-8316-6
  39 default                49 bg-default'
}
random-color() {
    randomColor.js "$@" |jq -re '.'
    # --seed "$(head -c 100 /dev/random)" 
}
colorfb-r() {
    local hue="$(random-color -f hex)"
    # hue=random
    reval chalk -t "{$(random-color -l dark --hue "$hue").bgHex('$(random-color -f hex -l light --hue "$hue")') $*}"
}
cc () {
    reval chalk -t "{hex('$(random-color -f hex -l dark)').bgHex('$(random-color-f -f hex -l light)') $*}"
}
random-color-test() {
    node -e "var randomColor = require('randomcolor'); // import the script
var color = randomColor({count: 1}); // a hex code for an attractive color
console.log(JSON.stringify(color))"|jq -re '.[]'
}