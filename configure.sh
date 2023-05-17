#!/bin/bash -eE

#----- To configure your Dapp server set at least these environment variables: -----
export NETWORK_TYPE=net.ton.dev
export EVERNODE_FQDN=your.domain.org
export LETSENCRYPT_EMAIL=your@email.org
export VALIDATOR_NAME=my_validator


#----- Next variables can be used as reasonable defaults: -----

export ADNL_PORT=30303
#
# Container memory limits
#
export NODE_MEMORY=64G 
export QSERVER_MEMORY=5G
export ARANGO_MEMORY=32G
export KAFKA_MEMORY=10G
export CONNECT_MEMORY=5G


export EVERNODE_GITHUB_REPO="https://github.com/tonlabs/ever-node"
export EVERNODE_GITHUB_COMMIT_ID="a800b66765424e7870929e676ac6ea203390ff01"
export EVERNODE_TOOLS_GITHUB_REPO="https://github.com/tonlabs/ever-node-tools.git"
export EVERNODE_TOOLS_GITHUB_COMMIT_ID="master"  # TODO, commit? 

Q_SERVER_GITHUB_REPO="https://github.com/tonlabs/ton-q-server"
Q_SERVER_GITHUB_COMMIT="0.57.0"

# This is a name of the internal (docker bridge) network. Set this name arbitrarily. 
export NETWORK=evernode_ds  

export COMPOSE_HTTP_TIMEOUT=120 # TODO: do we really need this?

# 
# Create internal network if not exists
#
docker network inspect $NETWORK >/dev/null 2>&1 ||  docker network create $NETWORK -d bridge


# Next lines create `deploy` directory as a copy of 
# `templates` directory and replace all {{VAR}} with enviroment variables
rm -rf deploy ; cp -R templates deploy
find deploy \
    -type f \( -name '*.yml' -o -name *.html \) \
    -not -path '*/ever-node/configs/*' \
    -exec ./templates/templater.sh {} \;

cp .htpasswd deploy/proxy
mv deploy/proxy/vhost.d/{host.yourdomain.com,$EVERNODE_FQDN}


# Run q-server
rm -rf ./deploy/q-server/build/ton-q-server
git clone ${Q_SERVER_GITHUB_REPO} --branch ${Q_SERVER_GITHUB_COMMIT} deploy/q-server/build/ton-q-server

./templates/templater.sh deploy/ever-node/start_node.sh  

echo "Success! Output files are saved in the ./deploy directory"

