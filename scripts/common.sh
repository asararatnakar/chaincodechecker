#!/bin/bash

START_TIME=$(date +%s)
env | grep CORE
printf "\n\n CCCHECKER EXECUTION STARTED \n\n"
cd /opt/gopath/src/github.com/hyperledger/fabric/examples/ccchecker

ORG="$1"
CONFIG="$2"
ENV="$3"
: ${ORG:="org1"}

if test "$ORG" = "org1"
then
  : ${CONFIG:="ccchecker1.json"}
  : ${ENV:="env1.json"}
  echo "----------- This is ORG1 ----------- "
elif test "$ORG" = "org2"
then
  : ${CONFIG:="ccchecker2.json"}
  : ${ENV:="env2.json"}
  echo "----------- This is ORG2 ----------- "
fi
./ccchecker -c $CONFIG -e $ENV
#printf "sleep for 80 seconds ...\n"
#sleep 80 ## FIXME: This looks ugly

#printf "\n\n======Pre-process execution time $(($(date +%s)-START_TIME)) secs==========\n\n"
#printf "\n ----- Starting 'Chaincode Checker' tool ----- \n\n"
#CCCHECKER_EXEC_TIME=$(date +%s)
#./ccchecker -c ccchecker2.json -e env2.json

printf "\n\n====== ccchecker execution time $(($(date +%s)-$START_TIME)) secs==========\n\n"
echo "  ____ ___  __  __ ____  _     _____ _____ _____ ____  "
echo " / ___/ _ \|  \/  |  _ \| |   | ____|_   _| ____|  _ \\ "
echo "| |  | | | | |\/| | |_) | |   |  _|   | | |  _| | | | |"
echo "| |__| |_| | |  | |  __/| |___| |___  | | | |___| |_| |"
echo " \____\___/|_|  |_|_|   |_____|_____| |_| |_____|____/ "
printf "\n\n"

exit 0
