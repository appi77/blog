#!/bin/sh

#  This script restarts the otiv transformation pods:
#    otiv-asset, otiv-config, otiv-publication, otiv-publisher
#  This does not do a rolling restart; instead all the transformation 
#    pods are completely shutdown before they're scaled back up
#
#  Usage: restartTransformationPods.sh <namespace>
#    The <namespace> argument is optional. If not provided, then the
#    operation is executed in the namespace for the current context

if [ $# -gt 1 ]; then
    echo "usage: restartTransformationPods.sh [ namespace ]"
    exit 1
fi

NAMESPACE=""
if [ "$1" != "" ]; then
    NAMESPACE="-n $1"
    echo "Stopping and starting transformation pods in namespace -> $1"
else
    namespace=`kubectl config view --minify -o jsonpath='{..namespace}'`
    if [ -z "$namespace" ]; then
        echo "Stopping and starting transformation pods in namespace -> default"
    else
        echo "Stopping and starting transformation pods in namespace -> $namespace"
    fi
fi
echo ""
sleep 4

replicasAsset=`kubectl $NAMESPACE get deployment otiv-asset -o=jsonpath='{.spec.replicas}'`
replicasConfig=`kubectl $NAMESPACE get deployment otiv-config -o=jsonpath='{.spec.replicas}'`
replicasPublication=`kubectl $NAMESPACE get deployment otiv-publication -o=jsonpath='{.spec.replicas}'`
replicasPublisher=`kubectl $NAMESPACE get deployment otiv-publisher -o=jsonpath='{.spec.replicas}'`

echo "# of replicas: asset       -> $replicasAsset"
echo "# of replicas: config      -> $replicasConfig"
echo "# of replicas: publication -> $replicasPublication"
echo "# of replicas: publisher   -> $replicasPublisher"
echo ""
echo "Scaling down IV transformation services ..."
sleep 4
kubectl $NAMESPACE scale --replicas=0 deployment otiv-asset otiv-config otiv-publication otiv-publisher
echo "Sleeping 60 seconds while services terminate ..."
sleep 60

echo ""
echo "Scaling up IV transformation services ..."
kubectl $NAMESPACE scale --replicas=$replicasAsset deployment otiv-asset
kubectl $NAMESPACE scale --replicas=$replicasConfig deployment otiv-config
kubectl $NAMESPACE scale --replicas=$replicasPublication deployment otiv-publication
kubectl $NAMESPACE scale --replicas=$replicasPublisher deployment otiv-publisher

