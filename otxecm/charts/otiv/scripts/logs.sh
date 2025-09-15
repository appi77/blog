#!/bin/bash

# Gathers logs for the Intelligent Viewing micro services for a namespace
# Usage: ./logs.sh <Namespace>
# The output goes to output/<Namespace>/<MM>-<DD>
# NOTE: executions of this script overwrite output made earlier in the day for a given namespace

usage()
{
    echo "Usage: logs.sh namespace"
}


BASEPATH="output/"
NAMESPACE=

while [ "$1" != "" ];
do
    case $1 in
        -h | --help )     usage
                          exit
                          ;;
        * )               if [ "$NAMESPACE" != "" ]
                          then
                              usage
                              exit 1
                          fi
                          NAMESPACE=$1
                          ;;
    esac
    shift
done

if [ "$NAMESPACE" = "" ]
then
    usage
    exit 1
fi

BASEPATH=$BASEPATH$NAMESPACE

timestamp=`date +%m-%d`
LOG_DIR="$BASEPATH/$timestamp"
mkdir -p "$LOG_DIR"
cd "$LOG_DIR"

IFS=$'\n'

# Takes IV "service" argument (i.e. "pubication", "highlight", etc.)
# Writes logs output to stdout for the "service" pods
function logsFromStdOut()
{
    echo "Gathering logs for $1"
    S_PODS=`kubectl -n $NAMESPACE get pods --no-headers -l app=$1 -o custom-columns=:metadata.name`
    PODS=($S_PODS)
    for POD in "${PODS[@]}"
    do
        kubectl logs -n $NAMESPACE $POD -c $1 > "$POD.log"
    done
}

# Takes java based IV "service" argument (i.e. "publisher")
# Copies logs from the /app/logs dir to a sub-directory corresponding to the pod id
function logsFromAppLogsDir()
{
    echo "Copying logs from /app/logs for $1"
    S_PODS=`kubectl -n $NAMESPACE get pods --no-headers -l app=$1 -o custom-columns=:metadata.name`
    PODS=($S_PODS)
    for POD in "${PODS[@]}"
    do
        mkdir -p $POD
        kubectl -n $NAMESPACE cp $POD:/app/logs $POD
    done
}

function logsFromOtds()
{
    # following line is relevant for 22.1 deployments and earlier
    #logsFromStdOut "otds"
    # following lines are relevant for 22.2 deployments and later
    S_PODS=`kubectl -n $NAMESPACE get pods --no-headers -l app.kubernetes.io/component=otdsws -o custom-columns=:metadata.name`
    PODS=($S_PODS)
    for POD in "${PODS[@]}"
    do
        kubectl logs -n $NAMESPACE $POD > "$POD.log"
    done
}

echo "Started writing otiv logs for namespace <$NAMESPACE> to $LOG_DIR"

logsFromStdOut "otiv-publication"
logsFromAppLogsDir "otiv-publication"
logsFromStdOut "otiv-publisher"
logsFromAppLogsDir "otiv-publisher"
logsFromStdOut "otiv-config"
logsFromStdOut "otiv-asset"
logsFromStdOut "otiv-highlight"
logsFromStdOut "otiv-viewer"
logsFromStdOut "otiv-markup"
logsFromStdOut "otiv-amqp"
logsFromOtds

echo "Completed writing otiv logs for namespace <$NAMESPACE> to $LOG_DIR"


