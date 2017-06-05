#!/bin/bash

UP_DOWN="$1"
CH_NAME="$2"
CLI_TIMEOUT="$3"

: ${CLI_TIMEOUT:="10000"}
: ${TLS:=false}
COMPOSE_FILE=docker-compose.yaml
COMPOSE_FILE_COUCH=docker-compose-couch.yaml
: ${CH_NAME:="mychannel"}

##TODO: For now hardcoding these values
: ${TOTAL_CC:="2"}
: ${TOTAL_CHANNELS:="2"}
export TOTAL_CC
export TOTAL_CHANNELS
export CUR_DIR=${PWD##*/}
function printHelp () {
	echo "Usage: ./network_setup <up|down> <\$channel-name> <\$cli_timeout> <couchdb>.\nThe arguments must be in order."
}

function validateArgs () {
	if [ -z "${UP_DOWN}" ]; then
		UP_DOWN="restart"
		echo "----- Setting the default option RESTART ------"
		return
	fi
	if [ -z "${CH_NAME}" ]; then
		echo "setting to default channel 'mychannel'"
		CH_NAME=mychannel
	fi
}

function clearContainers () {
        CONTAINER_IDS=$(docker ps -aq)
        if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" = " " ]; then
                echo "---- No containers available for deletion ----"
        else
                docker rm -f $CONTAINER_IDS
        fi
}

function removeUnwantedImages() {
        DOCKER_IMAGE_IDS=$(docker images | grep "dev\|none\|test-vp\|peer[0-9]-" | awk '{print $3}')
        if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" = " " ]; then
                echo "---- No images available for deletion ----"
        else
                docker rmi -f $DOCKER_IMAGE_IDS
        fi
}

function networkUp () {
    #Generate all the artifacts that includes org certs, orderer genesis block,
    # channel configuration transaction
    source generateArtifacts.sh $CH_NAME $TOTAL_CHANNELS

    TLS_ENABLED=$TLS CHANNEL_NAME=$CH_NAME TIMEOUT=$CLI_TIMEOUT docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH up -d 2>&1

    if [ $? -ne 0 ]; then
			echo "ERROR !!!! Unable to pull the images "
			exit 1
    fi
    docker logs -f org1.cli
}

function networkDown () {

    docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH -p $CUR_DIR down

    #Cleanup the chaincode containers
    clearContainers

    #Cleanup images
    removeUnwantedImages

    # remove orderer block and other channel configuration transactions and certs
    rm -rf channel-artifacts/*.block channel-artifacts/*.tx crypto-config
}

validateArgs

#Create the network using docker compose
if [ "${UP_DOWN}" == "up" ]; then
	networkUp
elif [ "${UP_DOWN}" == "down" ]; then ## Clear the network
	networkDown
elif [ "${UP_DOWN}" == "restart" ]; then ## Restart the network
	networkDown
	networkUp
else
	printHelp
	exit 1
fi
