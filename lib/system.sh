#!/usr/bin/env bash

set -eu

####################################### IMPORT FILES ######################################
# shellcheck source=/dev/null
source "${INSTALL_DIR}/lib/general.sh"

########################################## MAIN ###########################################
function systemUpdatePackages() {

    echo "systemUpdatePackages"

    local question_title="Обновить систему?"
    local question_text="Произвести автоматическое обновление установленных пакетов?"

    answer=$(askQuestion "${question_title}" "${question_text}")

    if [ "${answer}" == "${TRUE}" ]; then

        echo "$ROOT_PASS" | sudo -S apt-get -y install -f &> /dev/null
        echo "$ROOT_PASS" | sudo -S apt-get -y update &> /dev/null
        echo "$ROOT_PASS" | sudo -S apt-get -y upgrade &> /dev/null
        echo "$ROOT_PASS" | sudo -S apt-get -y autoremove &> /dev/null
        echo "$ROOT_PASS" | sudo -S apt-get -y clean &> /dev/null
        echo "$ROOT_PASS" | sudo -S apt-get -y autoclean &> /dev/null

    fi

}

function systemInstallPackages() {

    echo "systemInstallPackages"

    local modify="${FALSE}"
    local packages="python3-pip python3-dev build-essential libssl-dev \
        libffi-dev python3-setuptools python3-venv nginx wget git"

    for name_package in ${packages}; do

        installed=$(packageIsInstalled "${name_package}")

        if [ "${installed}" == "${FALSE}" ]; then
            echo "$ROOT_PASS" | sudo -S apt-get -y --force-yes install "$1" &> /dev/null
            modify="${TRUE}"
        fi

    done

    if [ "${modify}" == "${TRUE}" ]; then
        echo "$ROOT_PASS" | sudo -S apt-get -y install -f &> /dev/null
    fi

}

function systemInstallService() {

    echo "systemInstallService"
        
    serviceActive=$(serviceIsActive "${SERVICE_NAME}")

    if [ "${serviceActive}" == "${TRUE}" ]; then
        echo "$ROOT_PASS" | sudo -S systemctl stop "${SERVICE_NAME}" &> /dev/null
    fi

    local fileService="/etc/systemd/system/${SERVICE_NAME}.service"
    local fileServiceTemplate="${INSTALL_DIR}/etc/unit.service"

    if [ -f "${fileService}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${fileService}"
    fi

    echo "$ROOT_PASS" | sudo -S touch "${fileService}"

    while read -r string; do
        newString=$(eval echo "$string")
        echo "$ROOT_PASS" | sudo -S bash -c "echo ${newString} >> ${fileService}"
    done < "${fileServiceTemplate}"

    echo "$ROOT_PASS" | sudo -S systemctl daemon-reload &> /dev/null

}

function systemInstallUser() {

    echo "systemInstallUser"

    resultFind=$(grep -q "^${SERVICE_USER}:" /etc/passwd && echo "${TRUE}" || echo "${FALSE}")

    if [ "${resultFind}" == "${TRUE}" ]; then
        echo "$ROOT_PASS" | sudo -S chsh -s "/bin/false" "${SERVICE_USER}" &> /dev/null
        echo "$ROOT_PASS" | sudo -S usermod --home "${SERVICE_DIR}" "${SERVICE_USER}" &> /dev/null
    else
        echo "$ROOT_PASS" | sudo -S useradd -U "${SERVICE_GROUP}" -M -N -r -b "${SERVICE_DIR}" -s "/bin/false" "${SERVICE_USER}" &> /dev/null
    fi

    echo "$ROOT_PASS" | sudo -S usermod -L "${SERVICE_USER}"

}