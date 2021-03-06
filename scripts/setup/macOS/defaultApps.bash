#!/usr/bin/env bash

function set-defaults() {
    # use `mdls` to get these data (kMDItemContentType, kMDItemCFBundleIdentifier)
    local cf_emacs=org.gnu.Emacs
    local cf_iterm=com.googlecode.iterm2
    local cf_zopen=org.evar.Zopen
    local cf_mpv='io.mpv'

    ## Emacs
    duti -s $cf_emacs "public.plain-text" editor
    duti -s $cf_emacs "public.text" editor
    duti -s $cf_emacs "public.yaml" editor
    duti -s $cf_emacs "public.data" editor
    duti -s $cf_emacs "org.vim.cfg-file" editor
    duti -s $cf_emacs "public.python-script" editor
    duti -s $cf_emacs "public.shell-script" editor
    duti -s $cf_emacs "public.script" editor
    duti -s $cf_emacs "public.source-code" editor
    duti -s $cf_emacs .jl editor
    duti -s $cf_emacs .lua editor
    # duti -s $cf_emacs .pdf editor
    # duti -s $cf_emacs "" editor
    ## iTerm
    duti -s $cf_iterm ".mp3test" all
    # duti -s $cf_iterm "public.zip-archive" all
    # duti -s $cf_iterm "" all
    ## zopen
    duti -s $cf_zopen com.microsoft.waveform-audio all
    duti -s $cf_zopen public.mp3 all
    duti -s $cf_zopen public.mp2 all
    duti -s $cf_zopen .ogg all
    duti -s $cf_zopen .au all
    duti -s $cf_zopen .flac all
    duti -s $cf_zopen com.apple.m4a-audio all
    duti -s $cf_zopen public.mpeg-4-audio all
    duti -s $cf_zopen public.audio all
    duti -s $cf_zopen "public.zip-archive" all
    duti -s $cf_zopen "com.rarlab.rar-archive" all
    duti -s $cf_zopen ".rar" all
    duti -s $cf_zopen "org.idpf.epub-container" all
    duti -s $cf_zopen "public.mobi" all
    duti -s $cf_zopen ".azw3" all
    duti -s $cf_zopen ".azw" all
    duti -s $cf_zopen ".cbz" all
    duti -s $cf_zopen "com.yacreader.yacreader.cbz" all
    duti -s $cf_zopen .pdf all
    duti -s $cf_zopen "com.adobe.pdf" all
    ## mpv
    duti -s $cf_mpv .mp4 all
    duti -s $cf_mpv .m4v all
    duti -s $cf_mpv .mkv all
    duti -s $cf_mpv .avi all
    ##

}

set-defaults
