#!/bin/bash


# this script is used to refresh microblog container

#ENV VARS
source .env

while true; do
    # In the future the migration will be tested and the pipeline 
    # will require a manual approval to deploy the new version
    docker stop microblog
    docker build -t microblog:latest .
    docker run --name microblog -d -p 8000:5000 --rm --network microblog-network   -e DATABASE_URL=mysql+pymysql://microblog:$DB_PASSWORD@mysql/microblog   -e ELASTICSEARCH_URL=http://elasticsearch:9200   microblog:latest
    if [[ "$?" == "0" ]]; then
        break
    fi
    echo Deploy command failed, retrying in 5 secs...
    sleep 5
done
echo "microblog container is running"