# Gathers logs for the Intelligent Viewing micro services for a namespace
# Usage: .\logs.ps1 <Namespace>
#   or if your windows user or machine execution policy is not set to "Unrestricted"
# Usage: powershell.exe -executionpolicy bypass -file .\logs.ps1 <Namespace>
# The output goes to output/<Namespace>/<MM>-<DD>
# NOTE: executions of this script overwrite output made earlier in the day for a given namespace

$BASEPATH = "output/"
$NAMESPACE = ""


if ($args.Count -ne 1)
{
    Write-Host "Usage: logs.ps1 namespace"
    exit 1
}
else
{
    $NAMESPACE=$args[0]
    Write-Host "Namespace => $NAMESPACE"
}

$BASEPATH = "$BASEPATH$NAMESPACE"

$timestamp = Get-Date -Format "MM-dd"
$LOG_DIR="$BASEPATH/$timestamp"

mkdir "$LOG_DIR" -ErrorAction SilentlyContinue > $null
cd "$LOG_DIR"

# Takes IV "service" argument (i.e. "pubication", "highlight", etc.)
# Writes logs output to stdout for the "service" pods
function logsFromStdOut([string] $service)
{
    Write-Host "Gathering logs for $service"
    [array] $PODS = kubectl -n $NAMESPACE get pods --no-headers -l app=$service -o custom-columns=:metadata.name
    foreach ($POD in $PODS)
    {
        kubectl logs -n $NAMESPACE $POD -c $service > "$POD.log"
    }
}

# Takes java based IV "service" argument (i.e. "publisher")
# Copies logs from the /app/logs dir to a sub-directory corresponding to the pod id
function logsFromAppLogsDir([string] $service)
{
    Write-Host "Copying logs from /app/logs for $service"
    [array] $PODS = kubectl -n $NAMESPACE get pods --no-headers -l app=$service -o custom-columns=:metadata.name
    foreach ($POD in $PODS)
    {
        mkdir -p $POD -ErrorAction SilentlyContinue > $null
        kubectl -n $NAMESPACE cp ${POD}:/app/logs $POD
    }
}

function logsFromOtds([string] $service)
{
    # following line is relevant for 22.1 deployments and earlier
    logsFromStdOut "otds"
    # following lines are relevant for 22.2 deployments and later
    [array] $PODS = kubectl -n $NAMESPACE get pods --no-headers -l app.kubernetes.io/component=otdsws -o custom-columns=:metadata.name
    foreach ($POD in $PODS)
    {
        kubectl logs -n $NAMESPACE $POD > "$POD.log"
    }
}

Write-Host "Started writing otiv logs for <$NAMESPACE> to $LOG_DIR"

logsFromStdOut "otiv-publication"
logsFromAppLogsDir "otiv-publication"
logsFromStdOut "otiv-publisher"
logsFromAppLogsDir "otiv-publisher"
logsFromStdOut "otiv-config"
logsFromStdOut "otiv-asset"
logsFromStdOut "otiv-highlight"
logsFromStdOut "otiv-viewer"
logsFromStdOut "otiv-markup"
logsFromStdOut "rabbitmq"
logsFromOtds

cd ../../..

Write-Host "Completed writing otiv logs for <$NAMESPACE> to $LOG_DIR"

