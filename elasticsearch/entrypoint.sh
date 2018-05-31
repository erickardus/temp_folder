#!/bin/bash

set -e

CLUSTER_NAME="${CLUSTER_NAME:-my-application}"
NODE_NAME="${NODE_NAME:-node-1}"
RACK="${RACK:-r1}"
PATH_DATA="${PATH_DATA:-/var/lib/elasticsearch}"
PATH_LOGS="${PATH_LOGS:-/var/log/elasticsearch}"
BOOTSTRAP_MEM_LOCK="${BOOTSTRAP_MEM_LOCK:-false}"
NETWORK_HOST="${NETWORK_HOST:-0.0.0.0}"
HTTP_PORT="${HTTP_PORT:-9200}"
DISCOVERY_HOSTS="${DISCOVERY_HOSTS:-127.0.0.1}"
MIN_MASTER_NODES="${MIN_MASTER_NODES:-1}"
RECOVER_NODES="${RECOVER_NODES:-1}"
DESTRUCTIVE_REQ_NAME="${DESTRUCTIVE_REQ_NAME:-true}"

sed -i 's/CLUSTER_NAME/'"$CLUSTER_NAME"'/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/NODE_NAME/'"$NODE_NAME"'/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/RACK/'"$RACK"'/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's|PATH_DATA|'"$PATH_DATA"'|g' /etc/elasticsearch/elasticsearch.yml
sed -i 's|PATH_LOGS|'"$PATH_LOGS"'|g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/BOOTSTRAP_MEM_LOCK/'"$BOOTSTRAP_MEM_LOCK"'/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/NETWORK_HOST/'"$NETWORK_HOST"'/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/HTTP_PORT/'"$HTTP_PORT"'/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/MIN_MASTER_NODES/'"$MIN_MASTER_NODES"'/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/RECOVER_NODES/'"$RECOVER_NODES"'/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/DESTRUCTIVE_REQ_NAME/'"$DESTRUCTIVE_REQ_NAME"'/g' /etc/elasticsearch/elasticsearch.yml

#HAndles the comma separation problem. Ex 10.0.0.1,10.0.0.2 becomes "10.0.0.1","10.0.0.2"
SEPARATED_HOSTS=`echo \"$DISCOVERY_HOSTS\" | sed 's/,/","/g'`
sed -i "s/DISCOVERY_HOSTS/${SEPARATED_HOSTS}/g" /etc/elasticsearch/elasticsearch.yml


# Add elasticsearch as command if needed
if [ "${1:0:1}" =	 '-' ]; then
	set -- elasticsearch "$@"
fi

# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
	# Change the ownership of user-mutable directories to elasticsearch
	for path in \
		/usr/share/elasticsearch/data \
		/usr/share/elasticsearch/logs \
	; do
		chown -R elasticsearch:elasticsearch "$path"
	done
	
	set -- gosu elasticsearch "$@"
	#exec gosu elasticsearch "$BASH_SOURCE" "$@"
else 
	set -- gosu elasticsearch elasticsearch
fi

# As argument is not related to elasticsearch,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"