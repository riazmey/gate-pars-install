#!/usr/bin/env bash

set -eu

####################################### IMPORT FILES ######################################
# shellcheck source=/dev/null
source general.sh

########################################## MAIN ###########################################
function systemUpdatePackages() {

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

    chromeInstalled=$(packageIsInstalled "google-chrome-stable")

    if [ "${chromeInstalled}" == "${FALSE}" ]; then
        cd "/tmp" || exit
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &> /dev/null
        echo "$ROOT_PASS" | sudo -S dpkg -i --force-depends google-chrome-stable_current_amd64.deb &> /dev/null
        modify="${TRUE}"
    fi

    if [ "${modify}" == "${TRUE}" ]; then
        echo "$ROOT_PASS" | sudo -S apt-get -y install -f &> /dev/null
    fi

}

function systemInstallService() {

    local fileService="/etc/systemd/system/${SERVICE_NAME}.service"
    local fileTmpService="/tmp/${SERVICE_NAME}.service"

    if [ -f "${fileService}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${fileService}"
    fi

    if [ -f "${fileTmpService}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${fileTmpService}"
    fi

    echo "
[Unit]
Description=uWSGI instance to serve ${SERVICE_NAME} project
After=network.target

[Service]
User=${SERVICE_USER}
Group=www-data
WorkingDirectory=${SERVICE_DIR}
ExecStart=${SERVICE_DIR}/venv/bin/uwsgi --ini ${SERVICE_NAME}.ini

[Install]
WantedBy=multi-user.target" > "${fileTmpService}"

    echo "$ROOT_PASS" | sudo -S bash -c "cat ${fileTmpService} | tee ${fileService} > /dev/null"

    echo "$ROOT_PASS" | sudo -S systemctl daemon-reload
    echo "$ROOT_PASS" | sudo -S systemctl stop "${SERVICE_NAME}"
    echo "$ROOT_PASS" | sudo -S systemctl enable "${SERVICE_NAME}"
    echo "$ROOT_PASS" | sudo -S systemctl start "${SERVICE_NAME}"

}