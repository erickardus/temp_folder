How to create a cluster in your workstation
==============

1. Create a network for your containers

$ docker network create --subnet=172.18.0.0/16 els-net

2. Run 3 docker instances, each with a different an IP, using them in the DISCOVERY_HOSTS ENV to form the cluster

docker run -d --net els-net --ip 172.18.0.22 -e DISCOVERY_HOSTS=172.18.0.22,172.18.0.23,172.18.0.24 nlf/elasticsearch:6.4.1
docker run -d --net els-net --ip 172.18.0.23 -e DISCOVERY_HOSTS=172.18.0.22,172.18.0.23,172.18.0.24 nlf/elasticsearch:6.4.1
docker run -d --net els-net --ip 172.18.0.24 -e DISCOVERY_HOSTS=172.18.0.22,172.18.0.23,172.18.0.24 nlf/elasticsearch:6.4.1

