diraction-personal-config (){
	# TODO create missing (submitted issue)
    diraction-batch-create --create-missing-dir <<< "
        cel $cellar
        vdl  $HOME/Downloads/video
        dl  $HOME/Downloads
        tmp  $HOME/tmp
	jtmp $HOME/julia_tmp
	ktmp $HOME/tmp-kindle
"
}
antibody bundle "adrieankhisbe/diractions"
vcnpp() {
	vcsh night.sh add ~/scripts/
    vcsh night.sh commit -uno -am "." ; vcsh night.sh pull --no-edit ; vcsh night.sh push
}
inqcell() incell "$(gquote "$@")"
incell() {
    pushf "$cellar"
    eval "$@"
    popf
}
alias cellp="incell 'gcam . ; gl --no-edit ; gp'"
indl() {
    pushf ~/Downloads/
    eval "$@"
    popf
}
