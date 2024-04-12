#!/bin/bash


# this script is used to refresh microblog container

#ENV VARS
source .env

while true; do
    # Stop existing containers
    docker stop microblog
    docker stop elasticsearch
    docker stop mysql
    docker stop redis

    # Remove existing containers
    docker rm microblog
    docker rm elasticsearch
    docker rm mysql
    docker rm redis

    # Remove existing network
    docker network rm microblog-network

    # Remove existing volumes
    docker volume rm microblog-mysql-data
    docker volume rm microblog-elasticsearch-data

    # Remove existing images
    docker rmi microblog:latest
    docker rmi elasticsearch:8.11.1
    docker rmi mysql:latest
    docker rmi redis:alpine

    # Create network
    docker network create microblog-network

    # Create volumes
    docker volume create microblog-mysql-data
    docker volume create microblog-elasticsearch-data

    # Create mysql container
    docker run --name mysql -d --rm --network microblog-network   -e MYSQL_ROOT_PASSWORD=$DB_ADMIN_PASSWORD   -e MYSQL_DATABASE=microblog   -e MYSQL_USER=microblog   -e MYSQL_PASSWORD=$DB_PASSWORD   -v microblog-mysql-data:/var/lib/mysql   mysql:latest

    # Create elasticsearch container
    docker run --name elasticsearch -d --rm --network microblog-network   -e "discovery.type=single-node" -e xpack.security.enabled=false  -v microblog-elasticsearch-data:/usr/share/elasticsearch/data   elasticsearch:8.11.1

    # Start Redis container
    docker run --name redis -d --rm --network microblog-network redis:alpine

    # Create microblog container
    docker build -t microblog:latest .
    docker run --name microblog -d -p 8000:5000 --rm --network microblog-network   -e DATABASE_URL=mysql+pymysql://microblog:$DB_PASSWORD@mysql/microblog   -e ELASTICSEARCH_URL=http://elasticsearch:9200   microblog:latest
    if [[ "$?" == "0" ]]; then
        break
    fi
    echo Deploy command failed, retrying in 5 secs...
    sleep 5
done
echo "microblog container is running"