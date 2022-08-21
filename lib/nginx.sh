#!/usr/bin/env bash

set -eu

########################################## MAIN ###########################################
function nginxConfigUpdate() {

    echo "nginxConfigUpdate"

    local confFile="/etc/nginx/nginx.conf"
    local confFileTmp="/tmp/nginx.conf"
    local confFileTemplate="/tmp/nginx_template.conf"

    function readConfig() {

        echo "  nginxConfigUpdate.readConfig"

        local currentAreaHttp="${FALSE}"
        local excludesStringsInAreaHttp="# { }"

        while read -r string; do

            if [[ $string == *"http {"* ]]; then
                currentAreaHttp="${TRUE}"
                echo "httpAreaInsertionLocation" >> "${confFileTemplate}"
            fi

            if [ "${currentAreaHttp}" == "${TRUE}" ]; then

                thisExcludedPhrase="${FALSE}"

                for phrase in ${excludesStringsInAreaHttp}; do

                    if [[ $string == *"${phrase}"* ]]; then
                        thisExcludedPhrase="${TRUE}"
                        break
                    fi

                done

                if [[ "${thisExcludedPhrase}" == "${FALSE}" && -n ${string} ]]; then
                    parametr=$(echo "$string" | awk '{print $1}' )
                    value=$(echo "$string" | awk '{print $2}' | sed 's/;//')
                    parametrsHttp+=( "${parametr} ${value}" )
                fi

            else
                echo "${string}" >> "${confFileTemplate}"
            fi

            if [[ "${currentAreaHttp}" == "${TRUE}" && $string == *"}"* ]]; then
                currentAreaHttp="${FALSE}"
            fi

        done < "${confFile}"

    }

    function setParametrs() {

        echo "  nginxConfigUpdate.setParametrs"

        function setParametr() {

            if [ "$1" == "include" ]; then
                return 0
            fi

            local indexForSet="${FALSE}"
            local lengthSetParametr=${#parametrsHttp[@]}

            for (( indexSetParametr=0; $(( indexSetParametr < lengthSetParametr )); indexSetParametr++ )); do

                parametr=$(echo "${parametrsHttp[$indexSetParametr]}" | awk '{print $1}')

                if [ "${parametr}" == "$1" ]; then
                    indexForSet=${indexSetParametr}
                    break
                fi

            done

            if [ "${indexForSet}" == "${FALSE}" ]; then
                parametrsHttp+=( "$1 $2" )
            else
                parametrsHttp[indexForSet]="$1 $2"
            fi

        }

        local length=${#NGINX_CONF_PARAMS_FOR_SET[@]}
        for (( index=0; $(( index < length )); index++ )); do

            parametr=$(echo "${NGINX_CONF_PARAMS_FOR_SET[$index]}" | awk '{print $1}')
            value=$(echo "${NGINX_CONF_PARAMS_FOR_SET[$index]}" | awk '{print $2}')

            setParametr "${parametr}" "${value}"

        done

    }

    function writeConfigTemp() {

        echo "  nginxConfigUpdate.writeConfigTemp"

        local level=0

        while read -r string; do

            if [[ $string == *"}"* ]]; then
                level=$(( level-1 ))
            fi

            if [ "${string}" == "httpAreaInsertionLocation" ]; then

                echo "http {" >> "${confFileTmp}"

                local length=${#parametrsHttp[@]}
                for (( index=0; $(( index < length )); index++ )); do
                    echo "${NGINX_CONF_PARAMS_RETREAT}${parametrsHttp[$index]};" >> "${confFileTmp}"
                done

                echo "}" >> "${confFileTmp}"

            else

                local retreats=""
                for (( counterLevel=1; $(( counterLevel <= level )); counterLevel++ )); do
                    retreats="${NGINX_CONF_PARAMS_RETREAT}${retreats}"
                done

                local firstSymbol="${string:0:1}"
                if [[ "${firstSymbol}" == "#" ]]; then
                    echo "${string}" >> "${confFileTmp}"
                else
                    echo "${retreats}${string}" >> "${confFileTmp}"
                fi

            fi

            if [[ $string == *"{"* ]]; then
                level=$(( level+1 ))
            fi

        done < "${confFileTemplate}"

    }

    function writeConfig() {

        echo "  nginxConfigUpdate.writeConfig"

        local nginxConfigFileOld="${confFile}.old"

        if [ -f "${nginxConfigFileOld}" ]; then
            echo "$ROOT_PASS" | sudo -S rm -rf "${nginxConfigFileOld}"
        fi

        echo "$ROOT_PASS" | sudo -S cp "${confFile}" "${nginxConfigFileOld}"
        echo "$ROOT_PASS" | sudo -S bash -c "cat ${confFileTmp} | tee ${confFile} > /dev/null"

    }

    if [ -f "${confFileTmp}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${confFileTmp}"
    fi

    if [ -f "${confFileTemplate}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${confFileTemplate}"
    fi

    local parametrsHttp=()
    
    echo "$ROOT_PASS" | sudo -S systemctl stop nginx

    readConfig
    setParametrs
    writeConfigTemp
    writeConfig

}

function nginxSitesUpdate() {

    echo "nginxSitesUpdate"

    local dirSitesAvailable="/etc/nginx/sites-available"
    local dirSitesEnabled="/etc/nginx/sites-enabled"
    local fileSiteAvailableService="${dirSitesAvailable}/${SERVICE_NAME}"
    local fileSiteEnabledService="${dirSitesEnabled}/${SERVICE_NAME}"
    local fileTemplate="${INSTALL_DIR}/etc/nginx-site"
    local fileTmp="/tmp/${SERVICE_NAME}_sites_available"

    if [ -f "${fileTmp}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${fileTmp}"
    fi

    function writeConfigTemp() {

        echo "  nginxSitesUpdate.writeConfigTemp"

        local level=0
        while read -r string; do
            
            local resultString=""
            local retreats=""

            stringWhithParametrs=$(eval echo "$string")

            if [[ $stringWhithParametrs == *"{"* ]]; then
                level=$(( level+1 ))
            fi

            for (( counterLevel=1; $(( counterLevel <= level )); counterLevel++ )); do
                retreats="${NGINX_CONF_PARAMS_RETREAT}${retreats}"
            done

            resultString="${retreats}${stringWhithParametrs}"
            echo "${resultString}" >> "${fileTmp}"

            if [[ $stringWhithParametrs == *"}"* ]]; then
                level=$(( level-1 ))
            fi

        done < "${fileTemplate}"

    }

    function writeConfig() {

        echo "  nginxSitesUpdate.writeConfig"

        local fileSiteAvailableServiceOld="${fileSiteAvailableService}.old"

        if [ -f "${fileSiteAvailableService}" ]; then

            if [ -f "${fileSiteAvailableServiceOld}" ]; then
                echo "$ROOT_PASS" | sudo -S rm -rf "${fileSiteAvailableServiceOld}"
            fi

            echo "$ROOT_PASS" | sudo -S cp "${fileSiteAvailableService}" "${fileSiteAvailableServiceOld}"
            echo "$ROOT_PASS" | sudo -S rm -rf "${fileSiteAvailableService}"

        fi

        echo "$ROOT_PASS" | sudo -S bash -c "cat ${fileTmp} | tee ${fileSiteAvailableService} > /dev/null"

        if [ ! -f "${fileSiteEnabledService}" ]; then
            echo "$ROOT_PASS" | sudo -S sudo ln -s "${fileSiteAvailableService}" "${dirSitesEnabled}"
        fi

    }

    writeConfigTemp
    writeConfig

}

function nginxSitesActivate() {

    echo "$ROOT_PASS" | sudo -S systemctl daemon-reload
    echo "$ROOT_PASS" | sudo -S systemctl enable nginx
    echo "$ROOT_PASS" | sudo -S systemctl start nginx

}