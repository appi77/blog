#!/bin/bash

# This script  modifies log levels in your namespace's running publisher containers. The publisher
#   containers are not restarted as a result of invoking this script.
#   The updated log levels are in affect until the container(s) are restarted.
#
#  The different publisher modules with their default log levels are:
#   LOG_LEVEL_NETTY=ERROR
#   LOG_LEVEL_NETFLIX=ERROR
#   LOG_LEVEL_CONFIG=INFO
#   LOG_LEVEL_DISCOVERY=INFO
#   LOG_LEVEL_HAZELCAST=INFO
#   LOG_LEVEL_METRICS=INFO
#   LOG_LEVEL_SEQUENCING=INFO
#   LOG_LEVEL_ARTIFACTS=INFO
#   LOG_LEVEL_CONVERSION=INFO
#   LOG_LEVEL_RETRIEVAL=INFO
#   LOG_LEVEL_ZMQ=INFO
#   LOG_LEVEL_SPI=INFO
#   LOG_LEVEL_SPI_AJIRA=INFO
#   LOG_LEVEL_SPI_MKONDO=INFO
#   LOG_LEVEL_SPI_PITHOS=INFO
#   LOG_LEVEL_SPI_SOTERIA=INFO
#   LOG_LEVEL_SYSTEM=INFO
#   LOG_LEVEL_VERTX=INFO
#
# NOTE: that the above log level may be overridden by environment variables set by your helm
#   deployment. This kubectl command executed by this script will further override the log levels
#   for the duration of the container(s) life. To see log level env variables, execute:
#     kubectl -n <NAMESPACE> exec otiv-publisher-<*> -- env | grep LOG_LEVEL
#  
#  The different log level that can be set include:
#   ERROR, WARNING, INFO, DEBUG, TRACE
#
#  !! Add, modify, or delete the kubectl lines in this script's loop for your logging requirements.
#
#  Usage: setPublisherLogLevel.sh [ namespace ]
#    The <namespace> argument is optional. If not provided, the operation
#      is executed in the namespace for the current kubectl context.
#

if [ $# -gt 1 ]; then
    echo "usage: setPublisherLogLevel.sh [ namespace ]"
    exit 1
fi

NS=
if [ $# -eq 1 ]; then
    NS="-n $1"
    echo "Updating log levels for publisher containers in namespace -> $1"
else
    namespace=`kubectl config view --minify -o jsonpath='{..namespace}'`
    if [ -z "$namespace" ]; then
        echo "Updating log levels for publisher containers in namespace -> default"
    else
        echo "Updating log levels for publisher containers in namespace -> $namespace"
    fi
fi

echo ""
sleep 4

S_PODS=`kubectl $NS get pods --no-headers -l app=otiv-publisher -o custom-columns=:metadata.name`
PODS=($S_PODS)
for POD in "${PODS[@]}"
do
    kubectl $NS exec $POD -c otiv-publisher -- /bin/bash -c "sed -i 's/\\\${LOG_LEVEL_NETTY}/INFO/' /app/config/logback.xml"
    kubectl $NS exec $POD -c otiv-publisher -- /bin/bash -c "sed -i 's/\\\${LOG_LEVEL_METRICS}/DEBUG/' /app/config/logback.xml"
    kubectl $NS exec $POD -c otiv-publisher -- /bin/bash -c "sed -i 's/\\\${LOG_LEVEL_RETRIEVAL}/DEBUG/' /app/config/logback.xml"
    kubectl $NS exec $POD -c otiv-publisher -- /bin/bash -c "sed -i 's/\\\${LOG_LEVEL_SEQUENCING}/DEBUG/' /app/config/logback.xml"
    kubectl $NS exec $POD -c otiv-publisher -- /bin/bash -c "sed -i 's/\\\${LOG_LEVEL_SPI_AJIRA}/DEBUG/' /app/config/logback.xml"
    kubectl $NS exec $POD -c otiv-publisher -- /bin/bash -c "sed -i 's/\\\${LOG_LEVEL_CONFIG}/DEBUG/' /app/config/logback.xml"
    kubectl $NS exec $POD -c otiv-publisher -- /bin/bash -c "sed -i 's/\\\${LOG_LEVEL_SYSTEM}/DEBUG/' /app/config/logback.xml"
    kubectl $NS exec $POD -c otiv-publisher -- /bin/bash -c "sed -i 's/\\\${LOG_LEVEL_ARTIFACTS}/DEBUG/' /app/config/logback.xml"
done

