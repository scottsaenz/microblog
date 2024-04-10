#!/bin/bash
# this script is used to boot a Docker container
while true; do
    # In the future the migration will be tested and the pipeline 
    # will require a manual approval to deploy the new version
    flask db migrate
    flask db upgrade
    if [[ "$?" == "0" ]]; then
        break
    fi
    echo Deploy command failed, retrying in 5 secs...
    sleep 5
done
exec gunicorn -b :5000 --access-logfile - --error-logfile - microblog:app