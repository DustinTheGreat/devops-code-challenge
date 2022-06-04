#!/bin/bash

function deploy(){
    sls create-cert
    sls deploy
}

function get_hosted_zone(){
   HOSTED_ZONE=$(aws route53 list-hosted-zones-by-name |  jq --arg name "${CLIENT_URL}." -r '.HostedZones | .[] | select(.Name=="\($name)") | .Id' | awk -F/ '{print $NF}')
   echo $HOSTED_ZONE

}

function create_record(){
    sls  info >> sls_temp_info.txt
    cat sls_temp_info.txt | while read line 
    do
        if [[ "$line" == *"Target Domain:"* ]]; then

        target_temp=$(echo $line | awk '{print $3}')
            echo export TARGET_DOMAIN=$target_temp >> deploy-conf

        fi

    done
    source deploy-conf

    envsubst < "create-record.json" > "destination.json"
    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE --change-batch file://destination.json
    rm sls_temp_info.txt deploy-conf destination.json

}

if [[ ${CLIENT_URL} ]]; then
    printf "Found CLIENT_URL as: ${GREEN}${CLIENT_URL}.\n"
else
    echo 'No CLIENT_URL found. Check your deploy-conf. Exiting.'
    exit
fi
if [[ ${PROJECT_NAME} ]]; then
    printf "Found PROJECT_NAME as: ${GREEN}${PROJECT_NAME}${NC}.\n"
else
    echo 'No PROJECT_NAME found. Check your deploy-conf. Exiting.'
    exit
fi

deploy
get_hosted_zone
create_record
