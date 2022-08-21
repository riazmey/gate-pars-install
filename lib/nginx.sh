#!/usr/bin/env bash

set -eu

########################################## MAIN ###########################################
function nginxConfigUpdate() {

    function readConfig() {

        local currentAreaHttp="${FALSE}"
        local excludesStringsInAreaHttp="# { }"

        while read -r string; do

            if [[ $string == *"http {"* ]]; then
                currentAreaHttp="${TRUE}"
                echo "httpAreaInsertionLocation" >> "${NGINX_CONF_FILE_TEMPLATE}"
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
                echo "${string}" >> "${NGINX_CONF_FILE_TEMPLATE}"
            fi

            if [[ "${currentAreaHttp}" == "${TRUE}" && $string == *"}"* ]]; then
                currentAreaHttp="${FALSE}"
            fi

        done < "${NGINX_CONF_FILE}"

    }

    function setParametrs() {

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

        local level=0

        while read -r string; do

            if [[ $string == *"}"* ]]; then
                level=$(( level-1 ))
            fi

            if [ "${string}" == "httpAreaInsertionLocation" ]; then

                echo "http {" >> "${NGINX_CONF_FILE_TMP}"

                local length=${#parametrsHttp[@]}
                for (( index=0; $(( index < length )); index++ )); do
                    echo "${NGINX_CONF_PARAMS_RETREAT}${parametrsHttp[$index]};" >> "${NGINX_CONF_FILE_TMP}"
                done

                echo "}" >> "${NGINX_CONF_FILE_TMP}"

            else

                local retreats=""
                for (( counterLevel=1; $(( counterLevel <= level )); counterLevel++ )); do
                    retreats="${NGINX_CONF_PARAMS_RETREAT}${retreats}"
                done

                local firstSymbol="${string:0:1}"
                if [[ "${firstSymbol}" == "#" ]]; then
                    echo "${string}" >> "${NGINX_CONF_FILE_TMP}"
                else
                    echo "${retreats}${string}" >> "${NGINX_CONF_FILE_TMP}"
                fi

            fi

            if [[ $string == *"{"* ]]; then
                level=$(( level+1 ))
            fi

        done < "${NGINX_CONF_FILE_TEMPLATE}"

    }

    function writeConfig() {

        local nginxConfigFileOld="${NGINX_CONF_FILE}.old"

        if [ -f "${nginxConfigFileOld}" ]; then
            echo "$ROOT_PASS" | sudo -S rm -rf "${nginxConfigFileOld}"
        fi

        echo "$ROOT_PASS" | sudo -S cp "${NGINX_CONF_FILE}" "${nginxConfigFileOld}"
        echo "$ROOT_PASS" | sudo -S bash -c "cat ${NGINX_CONF_FILE_TMP} | tee ${NGINX_CONF_FILE} > /dev/null"
    }

    if [ -f "${NGINX_CONF_FILE_TMP}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${NGINX_CONF_FILE_TMP}"
    fi

    if [ -f "${NGINX_CONF_FILE_TEMPLATE}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${NGINX_CONF_FILE_TEMPLATE}"
    fi

    local parametrsHttp=()
    
    echo "$ROOT_PASS" | sudo -S systemctl stop nginx

    readConfig
    setParametrs
    writeConfigTemp
    writeConfig

    echo "$ROOT_PASS" | sudo -S systemctl daemon-reload
    echo "$ROOT_PASS" | sudo -S systemctl enable nginx
    echo "$ROOT_PASS" | sudo -S systemctl start nginx

}

function nginxSitesUpdate() {

    local fileSiteAvailableService="${NGINX_CONF_DIR_SITES_AVAILABLE}/${SERVICE_NAME}"
    local fileSiteEnabledService="${NGINX_CONF_DIR_SITES_ENABLED}/${SERVICE_NAME}"
    local fileTemplate="${INSTALL_DIR}/etc/nginx-site"

    if [ -f "${fileSiteAvailableService}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${fileSiteAvailableService}"
    fi

    if [ -f "${fileSiteEnabledService}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${fileSiteEnabledService}"
    fi

    local level=0
    while read -r string; do
        
        stringWhithParametrs=$(eval echo "$string")
        local resultString=""
        local endSymbol=""

        local retreats=""

        if [[ $string == *"{"* ]]; then
            
            for (( counterLevel=1; $(( counterLevel <= level )); counterLevel++ )); do
                retreats="${NGINX_CONF_PARAMS_RETREAT}${retreats}"
            done

            level=$(( level+1 ))

        elif [[ $string == *"}"* ]]; then

            level=$(( level-1 ))

            for (( counterLevel=1; $(( counterLevel <= level )); counterLevel++ )); do
                retreats="${NGINX_CONF_PARAMS_RETREAT}${retreats}"
            done

        else
            endSymbol=";"
        fi

        resultString="${retreats}${stringWhithParametrs}${endSymbol}"

        echo "$ROOT_PASS" | sudo -S bash -c "echo ${resultString} >> ${fileSiteAvailableService}"

    done < "${fileTemplate}"

    echo "$ROOT_PASS" | sudo -S sudo ln -s "${fileSiteAvailableService}" "${NGINX_CONF_DIR_SITES_ENABLED}"

}