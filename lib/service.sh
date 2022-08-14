#!/usr/bin/env bash

set -eu

########################################## MAIN ###########################################
function serviceMakeTreeDir() {

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