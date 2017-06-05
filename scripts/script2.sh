#!/bin/bash

START_TIME=$(date +%s)
apt-get update && apt-get install -y libltdl-dev

echo
echo "  ___            ____             ____ _     ___ "
echo " / _ \ _ __ __ _|___ \           / ___| |   |_ _|"
echo "| | | | '__/ _`` | __) |  _____  | |   | |    | | "
echo "| |_| | | | (_| |/ __/  |_____| | |___| |___ | | "
echo " \___/|_|  \__, |_____|          \____|_____|___|"
echo "           |___/                                 "
echo

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/cacerts/ca.example.com-cert.pem
####TODO: Do we need these values again ?
CORE_PEER_LOCALMSPID="Org2MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
CORE_PEER_ADDRESS=peer0.org2.example.com:7051

cp /etc/hyperledger/fabric/*.yaml /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/
cd /opt/gopath/src/github.com/hyperledger/fabric/examples/ccchecker
printf "sleep for 75 seconds ...\n"
sleep 75 ## FIXME: This looks ugly

printf "\n\n======Pre-process execution time $(($(date +%s)-START_TIME)) secs==========\n\n"
printf "\n ----- Starting 'Chaincode Checker' tool ----- \n\n"
CCCHECKER_EXEC_TIME=$(date +%s)
./ccchecker -c ccchecker2.json -e env2.json

printf "\n\n====== ccchecker execution time $(($(date +%s)-CCCHECKER_EXEC_TIME)) secs==========\n\n"
echo "  ____ ___  __  __ ____  _     _____ _____ _____ ____  "
echo " / ___/ _ \|  \/  |  _ \| |   | ____|_   _| ____|  _ \\ "
echo "| |  | | | | |\/| | |_) | |   |  _|   | | |  _| | | | |"
echo "| |__| |_| | |  | |  __/| |___| |___  | | | |___| |_| |"
echo " \____\___/|_|  |_|_|   |_____|_____| |_| |_____|____/ "
printf "\n\n"

exit 0
