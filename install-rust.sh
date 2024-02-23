#!/bin/bash  -ue

script_dir=$(dirname "$0")
cur_time=$(date +%Y%m%d-%H%M%S)

function backup_dotfile() {
    local _file=$1
    local _sfx=${2:-"${cur_time}"}

    if [[ -f "${_file}" ]] ; then
        cp -pv "${_file}" "${_file}.${_sfx}"
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

    local _org_file="${_file}.${_sfx}"
    local _bak_file="${_file}.${_bak}"

    if [[ ! -f "${_file}" && ! -f "${_org_file}" ]] ; then
        # 元々ファイルがなく、作成もされていない時は何もしなくて良い
        return 0
    fi

    if [[ -f "${_file}" && ! -f "${_org_file}" ]] ; then
        # 元々ファイルがなかったが、作成された時は、
        # 新規作成されたファイルのバックアップだけ取り、
        # 元の状態 (ファイルがない状態) に復元する
        echo "New file ${_file}"
        cat  "${_file}"
        mv -v  "${_file}" "${_file}.${_bak}"
        return 0
    fi

    # 元々ファイルがあった場合は、変更点を表示し、
    # 差分があればその内容のバックアップだけ取り、
    # 元の状態に復元する。
    echo "Change of ${_file}"
    if ! diff -s "${_file}" "${_file}.${_sfx}" ; then
        mv -v "${_file}" "${_file}.${_bak}"
    fi
    cp -pv "${_file}.${_sfx}" "${_file}"
    return 0
}

# まず、上書きされる可能性のある
# ディレクトリとファイルをバックアップする。

bak_dir="${cur_time}"
bak_dot_bef="before-rust.${cur_time}"
bak_dot_aft="after-rust.${cur_time}"

pushd "${HOME}"
backup_dotfile  '.bashrc'        "${bak_dot_bef}"
backup_dotfile  '.bash_profile'  "${bak_dot_bef}"
backup_dotfile  '.profile'       "${bak_dot_bef}"
backup_dotfile  '.zshenv'        "${bak_dot_bef}"

escape_directory  '.cargo'   "${bak_dir}"
escape_directory  '.rustup'  "${bak_dir}"

# インストール作業を行う。


# 設定ファイルに変更あればその内容をバックアップする。
# その後、インストール前にバックアップした内容に復元する。

restore_dotfile  '.bashrc'        "${bak_dot_bef}"  "${bak_dot_aft}"
restore_dotfile  '.bash_profile'  "${bak_dot_bef}"  "${bak_dot_aft}"
restore_dotfile  '.profile'       "${bak_dot_bef}"  "${bak_dot_aft}"
restore_dotfile  '.zshenv'        "${bak_dot_bef}"  "${bak_dot_aft}"

# リネームしていたディレクトリがあれば復元する。

restore_directory  '.cargo'   "${bak_dir}"
restore_directory  '.rustup'  "${bak_dir}"
