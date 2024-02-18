#!/bin/bash  -xue

script_dir=$(dirname "$0")
cur_time=$(date +%Y%m%d-%H%M%S)

function backup_dotfile() {
    local _file=$1
    local _sfx=${2:-"${cur_time}"}

    if [[ -f "${_file}" ]] ; then
        cp -v "${_file}" "${_file}.${_sfx}"
    fi
    return 0
}

function escape_directory() {
    local _dir=$1
    local _sfx=${2:-"${cur_time}"}

    if [[ -d "${_dir}" ]] ; then
        mv -v "${_dir}" "${_dir}.${_sfx}"
    fi
    return 0
}

function restore_directory() {
    local _dir=$1
    local _sfx=${2:-"${cur_time}"}

    if [[ -d "${_dir}.${_sfx}" && ! -d "${_dir}" ]] ; then
        mv -v "${_dir}.${_sfx}" "${_dir}"
    fi
    return 0
}

function restore_dotfile() {
    local _file=$1
    local _sfx=$2
    local _bak=$3

    echo "Change of ${_file}"
    if ! diff -s "${_file}" "${_file}.${sfx}" ; then
        mv -v "${_file}" "${_file}.${_bak}"
    fi
    cp -pv "${_file}.${sfx}" "${_file}"
    return 0
}

# まず、上書きされる可能性のある
# ディレクトリとファイルをバックアップする。

pushd "${HOME}"
backup_dotfile '.bashrc'        ".before-rust.${cur_time}"
backup_dotfile '.bash_profile'  ".before-rust.${cur_time}"

escape_directory ".cargo"   "${cur_time}"
escape_directory ".rustup"  "${cur_time}"

# インストール作業を行う。


# 設定ファイルに変更あればその内容をバックアップする。
# その後、インストール前にバックアップした内容に復元する。

restore_dotfile '.bashrc' "before-rust.${cur_time}" "after-rust.${cur_time}"
restore_dotfile '.bash_profile' "before-rust.${cur_time}" "after-rust.${cur_time}"

# リネームしていたディレクトリがあれば復元する。

restore_directory ".cargo" "${cur_time}"
restore_directory ".rustup" "${cur_time}"
