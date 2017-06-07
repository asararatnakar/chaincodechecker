## Endorser stress test using ccchecker tool with fabric docker-compose

[ccchecker](https://github.com/hyperledger/fabric/tree/master/examples/ccchecker) tool used in this sample to stress test the peer/endorser

### Prerequisites and setup: 

* [Docker](https://www.docker.com/products/overview) - v1.12 or higher
* [Docker Compose](https://docs.docker.com/compose/overview/) - v1.8 or higher
* [Git client](https://git-scm.com/downloads) - needed for clone commands
* Generate Docker images (using "make docker" in fabric repo)
* Install Go (required for compiling ccchecker code)

#### Genearte Artifacts
* Crypto material will be generated using the **cryptogen** tool (pre-built) from fabric and mounted to all peers, the orderering nodes. More details about using cryptogen tool [here](http://hyperledger-fabric.readthedocs.io/en/latest/getting_started.html#using-the-cryptogen-tool).
* An Orderer genesis block (genesis.block) and channel configuration transaction (mychannel.tx also anchorpeer update transactions Org1MSPanchors.tx & Org2MSPanchors.tx) has been pre generated using the **configtxgen** tool and placed within the _channel-artifacts_ folder.
  More details about using configtxgen tool [here](http://hyperledger-fabric.readthedocs.io/en/latest/getting_started.html#using-the-configtxgen-tool).

### Clone the repo and Launch the network
```
git clone https://github.com/asararatnakar/chaincodechecker
cd chaincodechecker
./network_setup.sh restart mychannel 10
```

Once you have completed the above setup, you will be provisioned a local network with following configuration:

* 3 Zookeepers
* 3 Kafka broker
* 3 Orderer services
* 2 Peer Orgs (each Org contains a leader/anchor peer and a non-leader peer)
* And a **CLI** Container

## How to use the ccchecker tool
__ccchecker__ is mounted to the **CLI** container(s) and executes the script.sh, which creates the default channel __mychannel__ and joins the peers on to this channel

With the following default configurations (Refer _ccchecker/ccchecker.json_ and _ccchecker/env.json_)
Concurrency & NumberOfInvokes:  __10__  , ChainName     : __mychannel__ ,  Name   : __mycc__

Outpiut would be some thing similar:
```
 --- Starting 'Chaincode Checker' tool --- 
    ...
	Time for invokes(ms): 1375
	Num successful invokes: 100(100)
	Num successful queries: 100(100)
Test complete
```

__NOTE__:  Fabric commit level used at the time of uploading the changes __c50e0dd1ca1ea96cb69503fc83a302c53eff96a6__


### execute cccheker on each cli container

```
docker exec -it peer0.org1.cli /bin/bash -c "./scripts/common.sh org1"

docker exec -it peer0.org2.cli /bin/bash -c "./scripts/common.sh org2"

docker exec -it peer1.org1.cli /bin/bash -c "./scripts/common.sh org1"

docker exec -it peer1.org2.cli /bin/bash -c "./scripts/common.sh org2"
```
