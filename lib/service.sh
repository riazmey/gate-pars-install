#!/usr/bin/env bash

set -eu

########################################## MAIN ###########################################
function serviceCreateAppIni() {

    echo "serviceCreateAppIni"

    local fileIni="${SERVICE_DIR}/app.ini"
    local fileIniTemplate="${INSTALL_DIR}/etc/app.ini"

    if [ -f "${fileIni}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${fileIni}"
    fi

    echo "$ROOT_PASS" | sudo -S touch "${fileIni}"

    while read -r string; do
        newString=$(eval echo "$string")
        echo "$ROOT_PASS" | sudo -S bash -c "echo ${newString} >> ${fileIni}"
    done < "${fileIniTemplate}"

    echo "$ROOT_PASS" | sudo -S systemctl daemon-reload &> /dev/null

}

function serviceCreateTreeDir() {

    echo "serviceCreateTreeDir"

    for currentDir in ${SERVICE_DIR_TREE}; do

        if [ -d "${currentDir}" ]; then
            rm -rf "${currentDir}"
        fi

        mkdir -p "${currentDir}"

        echo "$ROOT_PASS" | sudo -S mkdir -p "${currentDir}"
        echo "$ROOT_PASS" | sudo -S chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "${currentDir}"
        echo "$ROOT_PASS" | sudo -S chmod -R 644 "${currentDir}"

    done

}

function serviceCreateEnv() {

    echo "serviceCreateEnv"

    cd "${SERVICE_DIR}" || exit
    local dirEnv="${SERVICE_DIR}/env"

    if [ -d "${dirEnv}" ]; then
        rm -rf "${dirEnv}"
    fi

    python3 -m venv "${dirEnv}"

    # shellcheck source=/dev/null
    source "${dirEnv}/bin/activate"

    packagesPython="wheel requests selenium selenium-wire beautifulsoup4 \
        html5lib fake-useragent uwsgi flask"

    for namePackage in ${packagesPython}; do
        installPython3Package "${namePackage}"
    done

    deactivate

}

function serviceUpdateModules() {

    echo "serviceUpdateModules"

    gitRepoIsEnable=$(git status &> /dev/null && echo "${TRUE}" || echo "${FALSE}")

    if [ "${gitRepoIsEnable}" == "${TRUE}" ]; then
        git fetch --all && git reset --hard origin/main &> /dev/null
    else
        git clone "${SERVICE_GIT_REPO}" &> /dev/null
    fi
    
}

function serviceInstallChrome() {

    echo "serviceInstallChrome"

    bash "${INSTALL_DIR}/lib/install_chrome.sh"
    
}