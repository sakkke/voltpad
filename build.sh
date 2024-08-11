#!/bin/bash

set -e

PRODUCT_NAME='voltpad'

OUT_PATH=out
ASSETS_PATH=assets
THIRD_PARTY_PATH=third-party

BSDTAR_EXECUTABLE=bsdtar

function main {
    rm --recursive --force "${OUT_PATH}"
    mkdir "${OUT_PATH}"
    for target in "${@}"; do
        local codium_path="${OUT_PATH}/${target}"
        extract_codium "${target}" "${codium_path}"
        if [[ "${target}" == 'linux' ]]; then
            enable_portable_mode "${target}" "${codium_path}"
            install_extensions "${target}" "${codium_path}"
            update_settings_json "${target}" "${codium_path}"
        fi
        if [[ "${target}" == 'windows' ]]; then
            copy_data_from_linux "${target}" "${codium_path}"
        fi
        extract_volta "${target}" "${codium_path}"
        create_launcher "${target}" "${codium_path}"
        create_artifact "${target}" "${codium_path}"
    done
}

function codium_archive_name {
    local target="${1}"
    if [[ "${target}" == 'linux' ]]; then
        echo 'VSCodium-linux-x64-1.91.1.24193.tar.gz'
    elif [[ "${target}" == 'windows' ]]; then
        echo 'VSCodium-win32-x64-1.91.1.24193.zip'
    fi
}

function volta_archive_name {
    local target="${1}"
    if [[ "${target}" == 'linux' ]]; then
        echo 'volta-1.1.1-linux.tar.gz'
    elif [[ "${target}" == 'windows' ]]; then
        echo 'volta-1.1.1-windows.zip'
    fi
}

function launcher_name {
    local target="${1}"
    if [[ "${target}" == 'linux' ]]; then
        echo "${PRODUCT_NAME}"
    elif [[ "${target}" == 'windows' ]]; then
        echo "${PRODUCT_NAME}.cmd"
    fi
}

function extract_codium {
    local target="${1}"
    local codium_path="${2}"
    mkdir "${codium_path}"
    "${BSDTAR_EXECUTABLE}" --extract --file="${THIRD_PARTY_PATH}/$(codium_archive_name "${target}")" --directory="${codium_path}"
}

function enable_portable_mode {
    local target="${1}"
    local codium_path="${2}"
    mkdir "${codium_path}/data"
}

function install_extensions {
    local target="${1}"
    local codium_path="${2}"
    find "${THIRD_PARTY_PATH}/extensions" -name '*.vsix' | xargs --max-lines=1 "${codium_path}/bin/codium" --install-extension
}

function update_settings_json {
    local target="${1}"
    local codium_path="${2}"
    mkdir-cp "${ASSETS_PATH}/settings.json" "${codium_path}/data/user-data/User/settings.json"
}

function copy_data_from_linux {
    local target="${1}"
    local codium_path="${2}"
    cp --recursive "${OUT_PATH}/linux/data" "${codium_path}/data"
}

function extract_volta {
    local target="${1}"
    local codium_path="${2}"
    local volta_path="${codium_path}/volta"
    mkdir "${volta_path}"
    "${BSDTAR_EXECUTABLE}" --extract --file="${THIRD_PARTY_PATH}/$(volta_archive_name "${target}")" --directory="${volta_path}"
}

function create_launcher {
    local target="${1}"
    local codium_path="${2}"
    local launcher_name="$(launcher_name "${target}")"
    mkdir-cp "${ASSETS_PATH}/${launcher_name}" "${codium_path}/bin/${launcher_name}"
}

function create_artifact {
    local target="${1}"
    local codium_path="${2}"
    if [[ "${target}" == 'linux' ]]; then
        (cd "${codium_path}" && "${BSDTAR_EXECUTABLE}" --create --auto-compress --file="${OLDPWD}/${codium_path}.tar.gz" *)
    elif [[ "${target}" == 'windows' ]]; then
        (cd "${codium_path}" && "${BSDTAR_EXECUTABLE}" --create --auto-compress --file="${OLDPWD}/${codium_path}.zip" *)
    fi
}

function mkdir-cp {
    local path="${1}"
    local destination="${2}"
    mkdir --parents "$(dirname "${destination}")"
    cp "${path}" "${destination}"
}

main "${@}"
