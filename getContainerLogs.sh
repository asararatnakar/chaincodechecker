#!/bin/bash

function getLogs(){
	for (( i=0; i<3; i=$i+1))
	do
		docker logs zookeeper$i >& zookeeper$i.txt
		docker logs kafka$i >& kafka$i.txt
		docker logs orderer$i.example.com >& orderer$i.example.com.txt
		docker logs couchdb$i &> couchdb$i.txt
	done
	docker logs couchdb3 &> couchdb3.txt
	docker logs peer0.org1.example.com &> peer0.org1.example.com.txt
	docker logs peer1.org1.example.com &> peer1.org1.example.com.txt
	docker logs peer0.org2.example.com &> peer0.org2.example.com.txt
	docker logs peer1.org2.example.com &> peer1.org2.example.com.txt
	docker logs org1.cli &> org1.cli.txt
        DATE=`date +%Y_%m_%d_%H_%M_%S`	
	tar czf $DATE-logs.tar.gz *.txt
	rm -rf *.txt
}
getLogs
