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
backup_dotfile '.bashrc'        "${cur_time}"
backup_dotfile '.bash_profile'  "${cur_time}"

escape_directory ".cargo"   "${cur_time}"
escape_directory ".rustup"  "${cur_time}"

# インストール作業を行う。


# 設定ファイルと、念の為バックアップしていた内容を比較する。

echo "Change of .bashrc"
if ! diff -s .bashrc .bashrc.${cur_time} ; then
    mv -v .bashrc .bashrc.rust.${cur_time}
fi
cp -v .bashrc.${cur_time} .bashrc

echo "Change of .bash_profile"
if ! diff -s .bash_profile .bash_profile.${cur_time} ; then
    mv -v .bash_profile .bash_profile.rust.${cur_time}
fi
cp -v .bash_profile.${cur_time} .bash_profile

# リネームしていたディレクトリがあれば復元する。

restore_directory ".cargo" "${cur_time}"
restore_directory ".rustup" "${cur_time}"
