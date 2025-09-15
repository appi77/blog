
#  This script restarts the otiv transformation pods:
#    otiv-asset, otiv-config, otiv-publication, otiv-publisher
#  This does not do a rolling restart; instead all the transformation 
#    pods are completely shutdown before they're scaled back up
#
#  Usage: .\restartTransformationPods.ps1 <namespace>
#    or if your windows user or machine execution policy is not set to "Unrestricted"
#  Usage: powershell.exe -executionpolicy bypass -file .\restartTransformationPods.ps1 <namespace>

$NAMESPACE = ""
if ($args.Count -ne 1)
{
    Write-Host "Usage: restartTransformationPods.ps1 <namespace>"
    exit 1
}

$NAMESPACE = $args[0]
#Write-Host "Stopping and starting transformation pods in namespace -> $args[0]"
Write-Host "Stopping and starting transformation pods in namespace -> ", $args[0]
Write-Host ""
Start-Sleep -Seconds 4

$replicasAsset = kubectl -n $NAMESPACE get deployment otiv-asset -o=jsonpath='{.spec.replicas}'
$replicasConfig = kubectl -n $NAMESPACE get deployment otiv-config -o=jsonpath='{.spec.replicas}'
$replicasPublication = kubectl -n $NAMESPACE get deployment otiv-publication -o=jsonpath='{.spec.replicas}'
$replicasPublisher = kubectl -n $NAMESPACE get deployment otiv-publisher -o=jsonpath='{.spec.replicas}'
 
Write-Host "# of replicas: asset       -> $replicasAsset"
Write-Host "# of replicas: config      -> $replicasConfig"
Write-Host "# of replicas: publication -> $replicasPublication"
Write-Host "# of replicas: publisher   -> $replicasPublisher"
Write-Host ""
Write-Host "Scaling down IV transformation services ..."
Start-Sleep -Seconds 4
kubectl -n $NAMESPACE scale --replicas=0 deployment otiv-asset otiv-config otiv-publication otiv-publisher

Write-Host "Sleeping 60 seconds while services terminate ..."
Start-Sleep -Seconds 60
 
Write-Host ""
Write-Host "Scaling up IV transformation services ..."
kubectl -n $NAMESPACE scale --replicas=$replicasAsset deployment otiv-asset
kubectl -n $NAMESPACE scale --replicas=$replicasConfig deployment otiv-config
kubectl -n $NAMESPACE scale --replicas=$replicasPublication deployment otiv-publication
kubectl -n $NAMESPACE scale --replicas=$replicasPublisher deployment otiv-publisher

