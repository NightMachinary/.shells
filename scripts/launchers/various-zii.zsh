#!/usr/bin/env zsh

tmuxnewsh2 serve-dl caddy run --config ~/Caddyfile

tmuxnewsh2 vscode SERVICE_URL="https://marketplace.visualstudio.com/_apis/public/gallery" ITEM_URL="https://marketplace.visualstudio.com/items" code-server --bind-addr '127.0.0.1:7451'  --ignore-last-opened # --ignore-last-opened makes vsc open in its default window on each refresh. Use `https://code.zii.lilf.ir/?folder=/home/zii/code/` to open in specific paths.
##
borgdir=~/code/betterborg/
tmuxnew julia "dash -c 'cd $(gq $borgdir) && borg_admins=madscientistX $(gq "$(realpath2 python3)") $(gq $borgdir/stdborg.py)'"
tmuxnew julia_inline "dash -c 'cd $(gq $borgdir) && borg_admins=madscientistX TELEGRAM_TOKEN=$(gq $TELEGRAM_TOKEN) $(gq "$(realpath2 python3)") $(gq $borgdir/inline.py)'"

tmuxnew wirehole "cd ~/code/misc/wirehole && docker-compose up"

tmuxnew v2ray v2ray -config /usr/local/etc/v2ray/config.json
##
# tmuxnewsh2 trojan indir ~/code/misc/trojan-caddy-docker-compose docker-compose up

# Currently managed by systemd:
# tmuxnew trojan trojan --config /usr/local/etc/trojan/config.json
##
typeset -A artists
artists['Marjan Farsad']='https://open.spotify.com/artist/5sGy7zfcUWYPh3wHbyz4fn'
artists['Hani Niroo']='https://open.spotify.com/artist/07xBlQ8c7xhTa7IefYshum'
artists['Sogand']='https://open.spotify.com/artist/2mGkJsyXC8byI83UHSO4w1'
##
artists['Niaz Nawab']='https://open.spotify.com/artist/4hprwICrkEC8ule8JvCcJS'
artists['Aida Shahghasemi']='https://open.spotify.com/artist/1bQlJQRMtgj4p2gy9nN9Mz'
artists['Tara Tiba']='https://open.spotify.com/artist/0s6fPszrilIZ2kmduBE9N7'
artists['Rana Mansour']='https://open.spotify.com/artist/3zrjEdzGRRwrLHv3KQDDuB'
###
artists['Alexander Rybak']='https://open.spotify.com/artist/3LLNDXrxL4uxXtnUJS5XWM'
##
artists['Brian Eno']='https://open.spotify.com/artist/7MSUfLeTdDEoZiJPDSBXgi'
###
artists['Becky G']='https://open.spotify.com/artist/4obzFoKoKRHIphyHzJ35G3'
artists['Halsey']='https://open.spotify.com/artist/26VFTg2z8YR0cCuwLzESi2'
artists['AURORA']='https://open.spotify.com/artist/1WgXqy2Dd70QQOU7Ay074N'
artists['Selena Gomez']='https://open.spotify.com/artist/0C8ZW7ezQVs4URX5aX7Kqx'
artists['Demi Lovato']='https://open.spotify.com/artist/6S2OmqARrzebs0tKUEyXyp'
##
artists['Camila Cabello']='https://open.spotify.com/artist/4nDoRrQiYLoBzwC5BhVJzF'
artists['Fifth Harmony']='https://open.spotify.com/artist/1l8Fu6IkuTP0U5QetQJ5Xt'
##
artists['']=''
artists['']=''
artists['']=''
artists['']=''
tmuxnewshenv="rt_skip='$rt_skip' rt_e=(rss-engine-spotify) rt_notel=y rt_ge=(spotify-discography-get) rt_eud=0 rt_eid=$((3600*24*14))" tmuxnewsh rss-spotify rss-tsend ${(@v)artists}
##
