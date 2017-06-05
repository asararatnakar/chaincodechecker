#!/bin/bash

START_TIME=$(date +%s)
apt-get update && apt-get install -y libltdl-dev
echo
echo "  ____ ____            ____ _   _ _____ ____ _  _______ ____  "
echo " / ___/ ___|          / ___| | | | ____/ ___| |/ / ____|  _ \ "
echo "| |  | |      _____  | |   | |_| |  _|| |   | ' /|  _| | |_) |"
echo "| |__| |___  |_____| | |___|  _  | |__| |___| . \| |___|  _ < "
echo " \____\____|          \____|_| |_|_____\____|_|\_\_____|_| \_\\"
echo

CHANNEL_NAME="$1"
TOTAL_CHANNELS="$2"
TOTAL_CC="$3"

: ${CHANNEL_NAME:="mychannel"}
: ${TIMEOUT:="60"}
: ${TOTAL_CHANNELS:="2"}
: ${TOTAL_CC:="2"}

COUNTER=1
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/cacerts/ca.example.com-cert.pem

echo "Channel name : "$CHANNEL_NAME

verifyResult () {
	if [ $1 -ne 0 ] ; then
		printf "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!\n"
                printf "================== ERROR !!! FAILED to execute End-2-End Scenario ==================\n"
   		exit 1
	fi
}

setGlobals () {

	if [ $1 -eq 0 -o $1 -eq 1 ] ; then
		CORE_PEER_LOCALMSPID="Org1MSP"
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
		if [ $1 -eq 0 ]; then
			CORE_PEER_ADDRESS=peer0.org1.example.com:7051
		else
			CORE_PEER_ADDRESS=peer1.org1.example.com:7051
		fi
	else
		CORE_PEER_LOCALMSPID="Org2MSP"
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
		if [ $1 -eq 2 ]; then
			CORE_PEER_ADDRESS=peer0.org2.example.com:7051
		else
			CORE_PEER_ADDRESS=peer1.org2.example.com:7051
		fi
	fi

	env |grep CORE
}

createChannel() {
	setGlobals 0

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer channel create -o orderer0.example.com:7050 -c $CHANNEL_NAME$1 -f ./channel-artifacts/$CHANNEL_NAME$1.tx -t 10 >&log.txt
	else
		peer channel create -o orderer0.example.com:7050 -c $CHANNEL_NAME$1 -f ./channel-artifacts/$CHANNEL_NAME$1.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -t 10 >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Channel creation failed"
	printf "===================== Channel \"$CHANNEL_NAME$1\" is created successfully ===================== \n"
}

## Sometimes Join takes time hence RETRY atleast for 5 times
joinWithRetry () {
	peer channel join -b $CHANNEL_NAME$2.block  >&log.txt
	res=$?
	cat log.txt
	if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
		COUNTER=` expr $COUNTER + 1`
		echo "PEER$1 failed to join the channel, Retry after 2 seconds"
		sleep 2
		joinWithRetry $1 $2
	else
		COUNTER=1
	fi
        verifyResult $res "After $MAX_RETRY attempts, PEER$1 has failed to Join the Channel"
}

joinChannel () {
	for (( id=0; id<=3; id=$id+1 ))
	do
		setGlobals $id
		joinWithRetry $id $1
		printf "===================== PEER$id joined on the channel \"$CHANNEL_NAME$1\" ===================== \n"
		sleep 2
		echo
	done
}

updateAnchorPeers() {
  PEER=$1
  setGlobals $PEER

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer channel update -o orderer0.example.com:7050 -c $CHANNEL_NAME$2 -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors$2.tx >&log.txt
	else
		peer channel update -o orderer0.example.com:7050 -c $CHANNEL_NAME$2 -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors$2.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Anchor peer update failed"
	printf "===================== Anchor peers for org \"$CORE_PEER_LOCALMSPID\" on \"$CHANNEL_NAME$2\" is updated successfully ===================== \n"
}

installChaincode () {
	PEER=$1
	setGlobals $PEER
	peer chaincode install -n mycc$2 -v 1.0 -p github.com/hyperledger/fabric/examples/ccchecker/chaincodes/newkeyperinvoke >&log.txt
	res=$?
	cat log.txt
  verifyResult $res "Chaincode installation on remote peer PEER$PEER has Failed"
	printf "===================== Installed cc 'mycc$2' on remote peer PEER$PEER ===================== \n"
}

instantiateChaincode () {
	PEER=$1
	setGlobals $PEER
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	for (( cc=0; cc<$TOTAL_CC; cc=$cc+1 )) ## Num of chincodes
	do
		if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
			peer chaincode instantiate -o orderer2.example.com:7050 -C $CHANNEL_NAME$2 -n mycc$cc -v 1.0 -c '{"Args":[""]}' -P "OR	('Org1MSP.member','Org2MSP.member')" >&log.txt
		else
			peer chaincode instantiate -o orderer2.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME$2 -n mycc$cc -v 1.0 -c '{"Args":[""]}' -P "OR	('Org1MSP.member','Org2MSP.member')" >&log.txt
		fi
		res=$?
		cat log.txt
		verifyResult $res "Chaincode instantiation on PEER$PEER on channel '$CHANNEL_NAME$2' failed"
		printf "===================== Chaincode 'mycc$i' Instantiation on PEER$PEER on channel '$CHANNEL_NAME$2' is successful ===================== \n"
	done
}

for (( cc=0; cc<$TOTAL_CC; cc=$cc+1 )) ## Num of chincodes
do
	## Install chaincode on all peers (org1/org2)
	printf "Installing chaincode 'mycc$cc' on all peers...\n"
	for (( peerNum=0; peerNum<=3; peerNum=$peerNum+1 ))
	do
		installChaincode $peerNum $cc
	done
done

for (( iter=0; iter<$TOTAL_CHANNELS; iter=$iter+1 ))
do
	## Create channel
	printf "Creating channel..."
	createChannel $iter

	## Join all the peers to the channel
	printf "Having all peers join the channel...\n"
	joinChannel $iter

	## Set the anchor peers for each org in the channel
	printf "Updating anchor peers for org1...\n"
	updateAnchorPeers 0 $iter
	printf "Updating anchor peers for org2...\n"
	updateAnchorPeers 2 $iter

	#echo "Sleep for 80 secs ..."
	#sleep 80
done
#Instantiate chaincode on Peer2/Org2
printf "Instantiating chaincode on on each Organization\n"
instantiateChaincode 0 0
instantiateChaincode 2 1

cp /etc/hyperledger/fabric/*.yaml /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/
cd /opt/gopath/src/github.com/hyperledger/fabric/examples/ccchecker
printf "sleep for 20 seconds ...\n"
sleep 20
printf "\n\n======Pre-process execution time $(($(date +%s)-START_TIME)) secs==========\n\n"
printf "\n ----- Starting 'Chaincode Checker' tool ----- \n\n"
CCCHECKER_EXEC_TIME=$(date +%s)
./ccchecker -c ccchecker1.json -e env1.json

printf "\n\n====== ccchecker execution time $(($(date +%s)-CCCHECKER_EXEC_TIME)) secs==========\n\n"
echo "  ____ ___  __  __ ____  _     _____ _____ _____ ____  "
echo " / ___/ _ \|  \/  |  _ \| |   | ____|_   _| ____|  _ \\ "
echo "| |  | | | | |\/| | |_) | |   |  _|   | | |  _| | | | |"
echo "| |__| |_| | |  | |  __/| |___| |___  | | | |___| |_| |"
echo " \____\___/|_|  |_|_|   |_____|_____| |_| |_____|____/ "
printf "\n\n"

exit 0
