#!/bin/bash
if [ -z "$RUNDECK_APITOKEN" ]; then
    echo 'ERROR: Environment variable RUNDECK_APITOKEN must be set'
    exit 1
fi

if [ -z "$RUNDECK_PROJECTNAME" ]; then
    RUNDECK_PROJECTNAME=ci-project
fi

if [ -z "$RUNDECK_HOST" ]; then
    echo "INFO: Setting RUNDECK_HOST to default (localhost)"
    RUNDECK_HOST=localhost
fi

echo "Creating project $RUNDECK_PROJECTNAME"
curl -H "X-Rundeck-Auth-Token: $RUNDECK_APITOKEN" -H "Content-Type: application/json" http://$RUNDECK_HOST:4440/api/12/projects  --data '{"name": "'$RUNDECK_PROJECTNAME'"}' || { echo 'ERROR: problem creating project' ; exit 1; }


echo "Importing integration project from $JOB_LOCATION"

curl -H "X-Rundeck-Auth-Token: $RUNDECK_APITOKEN" -X POST http://$RUNDECK_HOST:4440/api/12/jobs/import  --data-urlencode "xmlBatch=$(cat $JOB_LOCATION)" --data "format=yaml" --data "project=$RUNDECK_PROJECTNAME"
