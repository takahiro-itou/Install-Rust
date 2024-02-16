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

# まず、上書きされる可能性のある
# ディレクトリとファイルをバックアップする。

pushd "${HOME}"
cp -pv .bashrc .bashrc.${cur_time}
cp -pv .bash_profile .bash_profile.${cur_time}

escape_directory ".cargo" "${cur_time}"
escape_directory ".rustup" "${cur_time}"

# インストール作業を行う。


# 設定ファイルと、念の為バックアップしていた内容を比較し
# 差分があれば、復元する。

echo "Change of .bashrc"
if ! diff -s .bashrc .bashrc.${cur_time} ; then
    mv -v .bashrc .bashrc.rust.${cur_time}
    cp -pv .bashrc.${cur_time} .bashrc
fi

echo "Change of .bash_profile"
if ! diff -s .bash_profile .bash_profile.${cur_time} ; then
    mv -v .bash_profile .bash_profile.rust.${cur_time}
    cp -pv .bash_profile.${cur_time} .bash_profile
fi


# リネームしていたディレクトリがあれば復元する。

restore_directory ".cargo" "${cur_time}"
restore_directory ".rustup" "${cur_time}"
