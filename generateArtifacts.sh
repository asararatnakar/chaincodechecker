#!/bin/bash +x
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#


#set -e

CHANNEL_NAME=$1
TOTAL_CHANNELS=$2
: ${CHANNEL_NAME:="mychannel"}
: ${TOTAL_CHANNELS:="2"}
echo $CHANNEL_NAME

#TODO: Change the whole logic to generate binaries for each run
#export FABRIC_ROOT=$PWD/../..
export FABRIC_CFG_PATH=$PWD
echo

OS_ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')

function generateCerts (){
	#CRYPTOGEN=$FABRIC_ROOT/release/$OS_ARCH/bin/cryptogen
	CRYPTOGEN=$FABRIC_CFG_PATH/bin/cryptogen

	if [ -f "$CRYPTOGEN" ]; then
            echo "Using cryptogen -> $CRYPTOGEN"
	else
	    echo "Building cryptogen"
	    make -C $FABRIC_ROOT release-all
	fi

	echo
	echo "##########################################################"
	echo "##### Generate certificates using cryptogen tool #########"
	echo "##########################################################"
	$CRYPTOGEN generate --config=./crypto-config.yaml
	echo
}

## Generate orderer genesis block , channel configuration transaction and anchor peer update transactions
function generateChannelArtifacts() {

	#CONFIGTXGEN=$FABRIC_ROOT/release/$OS_ARCH/bin/configtxgen
	CONFIGTXGEN=$FABRIC_CFG_PATH/bin/configtxgen
	if [ -f "$CONFIGTXGEN" ]; then
            echo "Using configtxgen -> $CONFIGTXGEN"
	else
	    echo "Building configtxgen"
	    make -C $FABRIC_ROOT release-all
	fi

	echo "##########################################################"
	echo "#########  Generating Orderer Genesis block ##############"
	echo "##########################################################"
	# Note: For some unknown reason (at least for now) the block file can't be
	# named orderer.genesis.block or the orderer will fail to launch!
	$CONFIGTXGEN -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block

	for (( i=0; i<$TOTAL_CHANNELS; i=$i+1 ))
	do
		echo
		echo "#################################################################"
		echo "### Generating channel configuration transaction 'channel.tx' ###"
		echo "#################################################################"
		$CONFIGTXGEN -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/$CHANNEL_NAME$i.tx -channelID $CHANNEL_NAME$i

		echo
		echo "#################################################################"
		echo "#######    Generating anchor peer update for Org1MSP   ##########"
		echo "#################################################################"
		$CONFIGTXGEN -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors$i.tx -channelID $CHANNEL_NAME$i -asOrg Org1MSP

		echo
		echo "#################################################################"
		echo "#######    Generating anchor peer update for Org2MSP   ##########"
		echo "#################################################################"
		$CONFIGTXGEN -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors$i.tx -channelID $CHANNEL_NAME$i -asOrg Org2MSP
		echo
	done
}

generateCerts
generateChannelArtifacts
