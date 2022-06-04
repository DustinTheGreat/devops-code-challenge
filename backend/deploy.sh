

function deploy(){
    sls create-cert
    sls deploy
}


function create_record(){
    sls  info >> peptides.txt
    cat peptides.txt | while read line 
    do
        if [[ "$line" == *"Target Domain:"* ]]; then

        target_temp=$(echo $line | awk '{print $3}')
            echo export TARGET_DOMAIN=$target_temp >> deploy-conf

        fi

    done
    rm peptides.txt
    source deploy-conf

    envsubst < "test.json" > "destination.json"
    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE --change-batch file://destination.json
    rm destination.json
    rm deploy-conf
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
create_record
