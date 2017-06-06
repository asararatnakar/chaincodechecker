#!/bin/bash

START_TIME=$(date +%s)
apt-get update && apt-get install -y libltdl-dev

echo
echo " ____  _____ _____ ____    _            ____ _     ___ "
echo "|  _ \| ____| ____|  _ \  / |          / ___| |   |_ _|"
echo "| |_) |  _| |  _| | |_) | | |  _____  | |   | |    | | "
echo "|  __/| |___| |___|  _ <  | | |_____| | |___| |___ | | "
echo "|_|   |_____|_____|_| \_\ |_|          \____|_____|___|"
echo


ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/cacerts/ca.example.com-cert.pem
####TODO: Do we need these values again ?
CORE_PEER_LOCALMSPID="Org2MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
CORE_PEER_ADDRESS=peer1.org1.example.com:7051

cp /etc/hyperledger/fabric/*.yaml /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/
printf "\n\nReady to execute the ccchecker\n\n"
exit 0
