#!/usr/bin/env bash

set -eu

########################################## MAIN ###########################################
function serviceCreateTreeDir() {

    echo "serviceCreateTreeDir"

    for currentDir in ${SERVICE_DIR_TREE}; do

        if [ -d "${currentDir}" ]; then
            echo "$ROOT_PASS" | sudo -S rm -rf "${currentDir}"
        fi

        echo "$ROOT_PASS" | sudo -S mkdir -p "${currentDir}"

    done

}

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

function serviceCreateEnv() {

    echo "serviceCreateEnv"

    local dirTmpService="/tmp/${SERVICE_NAME}"
    local dirTmpServiceEnv="${dirTmpService}/env"
    local dirEnv="${SERVICE_DIR}/env"

    if [ -d "${dirTmpService}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${dirTmpService}"
    fi

    mkdir -p "${dirTmpServiceEnv}"
    python3 -m venv "${dirTmpServiceEnv}"

    # shellcheck source=/dev/null
    source "${dirTmpServiceEnv}/bin/activate"

    packagesPython="wheel requests selenium selenium-wire beautifulsoup4 \
        html5lib fake-useragent uwsgi flask"

    for namePackage in ${packagesPython}; do
        installPython3Package "${namePackage}"
    done

    deactivate

    if [ -d "${dirEnv}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${dirEnv}"
    fi

    echo "$ROOT_PASS" | sudo -S cp -rf "${dirTmpServiceEnv}" "${SERVICE_DIR}"

}

function serviceUpdateModules() {

    echo "serviceUpdateModules"

    gitRepoIsEnable=$(git status &> /dev/null && echo "${TRUE}" || echo "${FALSE}")

    if [ "${gitRepoIsEnable}" == "${TRUE}" ]; then
        echo "$ROOT_PASS" | sudo -S git fetch --all && git reset --hard origin/main &> /dev/null
    else
        echo "$ROOT_PASS" | sudo -S git clone "${SERVICE_GIT_REPO}" &> /dev/null
    fi
    
}

function serviceInstallChrome() {

    echo "serviceInstallChrome"

    bash "${INSTALL_DIR}/lib/install_chrome.sh"
    
}

function serviceEnable() {

    echo "serviceEnable"

    echo "$ROOT_PASS" | sudo -S chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "${SERVICE_DIR}"
    echo "$ROOT_PASS" | sudo -S chmod -R 644 "${SERVICE_DIR}"

    chromeDriverExcecutable
    
}