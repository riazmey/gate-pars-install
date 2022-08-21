#!/usr/bin/env bash

set -eu

####################################### IMPORT FILES ######################################
# shellcheck source=/dev/null
source "${INSTALL_DIR}/lib/general.sh"

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

    local dirTmpServiceEnv="${TEMPORARY_DIR}/env"
    local dirEnv="${SERVICE_DIR}/env"

    if [ -d "${dirTmpServiceEnv}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${dirTmpServiceEnv}"
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

    dirGit="${SERVICE_DIR}/.git"
    dirGitTmp="${TEMPORARY_DIR}/.git"

    if [ -d "${dirGit}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${dirGit}"
    fi

    if [ -d "${dirGitTmp}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${dirGitTmp}"
    fi

    echo "$ROOT_PASS" | sudo -S git clone "${SERVICE_GIT_REPO_MODULES}" "${dirGitTmp}" &> /dev/null
    echo "$ROOT_PASS" | sudo -S cp -rf "${dirGitTmp}" "${SERVICE_DIR}"
    
}

function serviceInstallChrome() {

    echo "serviceInstallChrome"

    bash "${INSTALL_DIR}/lib/install_chrome.sh"
    
}

function serviceStop() {

    echo "serviceStop"

    serviceActive=$(serviceIsActive "${SERVICE_NAME}")

    if [ "${serviceActive}" == "${TRUE}" ]; then
        echo "$ROOT_PASS" | sudo -S systemctl stop "${SERVICE_NAME}" &> /dev/null
    fi
    
}

function serviceEnable() {

    echo "serviceEnable"

    local fileApp="${SERVICE_DIR}/app.py"

    echo "$ROOT_PASS" | sudo -S chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "${SERVICE_DIR}"
    echo "$ROOT_PASS" | sudo -S chmod -R 644 "${SERVICE_DIR}"

    chromeDriverExcecutable

    if [ -f "${fileApp}" ]; then
        echo "$ROOT_PASS" | sudo -S chmod +x "${fileApp}"
    fi

    echo "$ROOT_PASS" | sudo -S systemctl enable "${SERVICE_NAME}" &> /dev/null
    echo "$ROOT_PASS" | sudo -S systemctl start "${SERVICE_NAME}" &> /dev/null
    
}