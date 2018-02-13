[CmdletBinding()]
param(
    [string] $datacenter = 'test-integration',
    [string] $domain = 'integrationtest',
    [int] $port = 8550,
    [string] $bindIp = '192.168.3.25',
    [string] $serverIp = $(throw 'Please specify the IP address of the consul server')
)

$ErrorActionPreference = 'Stop'

$commonParameterSwitches =
    @{
        Verbose = $PSBoundParameters.ContainsKey('Verbose');
        Debug = $false;
        ErrorAction = 'Stop'
    }

# ------------------ START FUNCTIONS ----------------------------

function Disconnect-ConsulFromCluster
{
    [CmdletBinding()]
    param(
        [string] $consulPath,
        [string] $consulLocalUrl
    )

    Write-Verbose "Disconnect-ConsulFromCluster - param consulPath = $consulPath"
    Write-Verbose "Disconnect-ConsulFromCluster - param consulLocalUrl = $consulLocalUrl"

    $ErrorActionPreference = 'Stop'

    $commonParameterSwitches =
        @{
            Verbose = $PSBoundParameters.ContainsKey('Verbose');
            Debug = $false;
            ErrorAction = 'Stop'
        }

    Write-Verbose "Disconnecting from the consul cluster ...."

    $arguments = "leave -http-addr=$($consulLocalUrl)"
    return Start-Process `
        -FilePath $consulPath `
        -ArgumentList $arguments `
        -NoNewWindow `
        @commonParameterSwitches
}

function Set-ConsulKV
{
    [CmdletBinding()]
    param(
        [string] $consulPath,
        [string] $consulLocalUrl
    )

    Write-Verbose "Set-ConsulKV - param consulPath = $consulPath"
    Write-Verbose "Set-ConsulKV - param consulLocalUrl = $consulLocalUrl"

    $ErrorActionPreference = 'Stop'

    $commonParameterSwitches =
        @{
            Verbose = $PSBoundParameters.ContainsKey('Verbose');
            Debug = $false;
            ErrorAction = 'Stop'
        }

    $kvDirectory = $PSScriptRoot
    $files = Get-ChildItem -Path $kvDirectory\* -Include *.yaml -Recurse
    foreach($file in $files)
    {
        Write-Output "Processing $file ..."

        $lines = Get-Content $file.FullName | Out-String
        $yamlObj = ConvertFrom-Yaml $lines
        foreach($entry in $yamlObj.config)
        {
            $key = $entry.key

            if ([bool]($entry.PSobject.Properties.name -match "file"))
            {
                Write-Verbose "Reading from file .."
                $fileName = $entry.file
                $path = Join-Path (Split-Path -Parent -Path $file.FullName) $fileName
                $value = Get-Content $path | Out-String
            }
            else
            {
                Write-Verbose "Reading from property .."
                $value = $entry.value
            }

            Write-Output "    Setting: $key to $value"
            Start-Process `
                -FilePath $consulPath `
                -ArgumentList "kv put -http-addr=$consulLocalUrl $key `"$value`"" `
                -NoNewWindow `
                -Wait
        }
    }
}

function Start-Consul
{
    [CmdletBinding()]
    param(
        [string] $consulPath,
        [string] $datacenter,
        [string] $domain,
        [int] $port,
        [string] $bindIp,
        [string] $serverIp
    )

    Write-Verbose "Start-Consul - param consulPath = $consulPath"
    Write-Verbose "Start-Consul - param datacenter = $datacenter"
    Write-Verbose "Start-Consul - param domain = $domain"
    Write-Verbose "Start-Consul - param port = $port"
    Write-Verbose "Start-Consul - param bindIp = $bindIp"
    Write-Verbose "Start-Consul - param serverIp = $serverIp"

    $ErrorActionPreference = 'Stop'

    $commonParameterSwitches =
        @{
            Verbose = $PSBoundParameters.ContainsKey('Verbose');
            Debug = $false;
            ErrorAction = 'Stop'
        }

    $consulTempDir = Join-Path $PSScriptRoot 'consul'
    if (Test-Path $consulTempDir)
    {
        Remove-Item -Path $consulTempDir -Recurse -Force
    }

    New-Item -Path $consulTempDir -ItemType Directory | Out-Null

    $dataDir = Join-Path $consulTempDir 'consul_data'
    if (Test-Path $dataDir)
    {
        Remove-Item -Path $dataDir -Recurse -Force
    }

    $arguments = "agent -data-dir $dataDir -disable-host-node-id -bind $bindIp -datacenter $datacenter -domain $domain -http-port $port -retry-join $serverIp"
    Write-Verbose "Starting consul with arguments: $arguments"
    return Start-Process `
        -FilePath $consulPath `
        -ArgumentList $arguments `
        -PassThru `
        -NoNewWindow `
        -RedirectStandardOutput (Join-Path $consulTempDir 'output.out') `
        -RedirectStandardError (Join-Path $consulTempDir 'error.out') `
        @commonParameterSwitches
}

# ------------------------ END FUNCTIONS --------------------------------------

try
{
    if (-not (Get-Module -ListAvailable -Name powershell-yaml))
    {
        Install-Module -Name 'powershell-yaml' -Scope CurrentUser -
    }

    Import-Module powershell-yaml

    $consulPath = Join-Path (Join-Path (Split-Path $PSScriptRoot -Parent) 'consul') 'consul.exe'
    $consulLocalUrl = "http://localhost:$($port)"

    $process = Start-Consul `
        -consulPath $consulPath `
        -datacenter $datacenter `
        -domain $domain `
        -port $port `
        -bindIp $bindIp `
        -serverIp $serverIp `
        @commonParameterSwitches
    try
    {
        Write-Output "Waiting for consul to connect to the cluster ..."
        Start-Sleep -Seconds 10

        Write-Output "Setting consul k-v's ..."
        Set-ConsulKV `
            -consulPath $consulPath `
            -consulLocalUrl $consulLocalUrl `
            @commonParameterSwitches
    }
    finally
    {
        Disconnect-ConsulFromCluster `
            -consulPath $consulPath `
            -consulLocalUrl $consulLocalUrl `
            @commonParameterSwitches

        Write-Output "Stopping consul ...."
    }
}
catch
{
    $currentErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    try
    {
        Write-Error $errorRecord.Exception
        Write-Error $errorRecord.ScriptStackTrace
        Write-Error $errorRecord.InvocationInfo.PositionMessage
    }
    finally
    {
        $ErrorActionPreference = $currentErrorActionPreference
    }

    # rethrow the error
    throw $_.Exception
}
