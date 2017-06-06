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

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/cacerts/ca.example.com-cert.pem
####TODO: Do we need these values again ?
CORE_PEER_LOCALMSPID="Org2MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
CORE_PEER_ADDRESS=peer1.org2.example.com:7051

cp /etc/hyperledger/fabric/*.yaml /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/
#cd /opt/gopath/src/github.com/hyperledger/fabric/examples/ccchecker
printf "\n\nReady to execute the ccchecker\n\n"
exit 0
