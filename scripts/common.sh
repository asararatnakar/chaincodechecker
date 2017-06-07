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
  : ${CONFIG:="testdata/ccchecker1.json"}
  : ${ENV:="testdata/env1.json"}
  echo "----------- This is ORG1 ----------- "
elif test "$ORG" = "org2"
then
  : ${CONFIG:="testdata/ccchecker2.json"}
  : ${ENV:="testdata/env2.json"}
fi
printf "\n -------- Using following configurations --------\n"
echo "$CONFIG"
echo "$ENV"
printf "\n ------------------------------------------------\n"
./ccchecker -c $CONFIG -e $ENV

printf "\n\n====== ccchecker execution time $(($(date +%s)-$START_TIME)) secs==========\n\n"
echo "  ____ ___  __  __ ____  _     _____ _____ _____ ____  "
echo " / ___/ _ \|  \/  |  _ \| |   | ____|_   _| ____|  _ \\ "
echo "| |  | | | | |\/| | |_) | |   |  _|   | | |  _| | | | |"
echo "| |__| |_| | |  | |  __/| |___| |___  | | | |___| |_| |"
echo " \____\___/|_|  |_|_|   |_____|_____| |_| |_____|____/ "
printf "\n\n"

exit 0
