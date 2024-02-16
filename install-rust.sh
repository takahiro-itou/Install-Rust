#!/bin/bash  -xue

script_dir=$(dirname "$0")
cur_time=$(date +%Y%m%d-%H%M%S)

function escape_directory() {
    local _dir=$1
    local _sfx=${2:-"${cur_time}"}

    if [[ -d "${_dir}" ]] ; then
        mv -v "${_dir}" "${_dir}.${sfx}"
    fi
    return 0
}

function restore_directory() {
    local _dir=$1
    local _sfx=${2:-"${cur_time}"}

    if [[ -d "${_dir}.${sfx}" && ! -d "${_dir}" ]] ; then
        mv -v "${_dir}.${sfx}" "${_dir}"
    fi
    return 0
}
