#!/bin/bash -eE

#----- To configure your Dapp server set at least these environment variables: -----
# NETWORK_TYPE - net.ton.dev or net.ton.dev - same name as corresponding github repo for download global config
export NETWORK_TYPE=net.ton.dev
export EVERNODE_FQDN=your.domain.org
export LETSENCRYPT_EMAIL=your@email.org

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

# Node and tools repo and commit id
export EVERNODE_GITHUB_REPO="https://github.com/tonlabs/ever-node"
export EVERNODE_GITHUB_COMMIT_ID="f19c7d0964dec1cf2f18e50600babc057f90e22a"
export EVERNODE_TOOLS_GITHUB_REPO="https://github.com/tonlabs/ever-node-tools.git"
export EVERNODE_TOOLS_GITHUB_COMMIT_ID="master"

Q_SERVER_GITHUB_REPO="https://github.com/tonlabs/ton-q-server"
Q_SERVER_GITHUB_COMMIT="0.65.4"

# This is a name of the internal (docker bridge) network. Set this name arbitrarily. 
export NETWORK=evernode_ds  

export COMPOSE_HTTP_TIMEOUT=120 # TODO: do we really need this?

# Install latest yq
YQ_LATEST_URL="$(curl -sS -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r '.assets[]|select(.name == "yq_linux_amd64")|.browser_download_url')"
sudo wget "$YQ_LATEST_URL" -O /usr/local/bin/yq && sudo chmod +x /usr/local/bin/yq

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
