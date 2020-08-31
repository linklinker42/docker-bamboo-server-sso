#!/bin/bash
set -e

# if [ ! -z ${BROKER_CLIENT_URI} ]; then
#     xmlstarlet ed --inplace -u '/application-configuration/properties/property[@name="bamboo.jms.broker.client.uri"]' -v "failover:($BROKER_CLIENT_URI?wireFormat.maxInactivityDuration=300000)?maxReconnectAttempts=10&initialReconnectDelay=15000" /var/atlassian/application-data/bamboo/bamboo.cfg.xml
# fi

# Normally this would be the actual start-up script.
# Atlassian didn't use Python for the Bamboo Docker image
# and I'm not going to rework their shell script at the moment.
# This just contains our script to copy the SSO files and generate
# the Tomcat server.xml and login.ftl files with our passed environmental variables.
python3 ./entrypoint.py

# Atlassian start-up script for Bamboo.
./entrypoint.sh
