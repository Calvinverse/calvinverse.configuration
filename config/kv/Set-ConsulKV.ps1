[CmdletBinding()]
param(
    [string] $consulPath = (Join-Path $PSScriptRoot 'consul.exe'),
    [string] $datacenter = 'test-integration',
    [string] $domain = 'integrationtest',
    [int] $port = 8500,
    [string] $serverIp = $(throw 'Please specify the IP address of the consul server')
)

Write-Verbose "Set-ConsulKV - param consulPath = $consulPath"
Write-Verbose "Set-ConsulKV - param datacenter = $datacenter"
Write-Verbose "Set-ConsulKV - param domain = $domain"
Write-Verbose "Set-ConsulKV - param port = $port"
Write-Verbose "Set-ConsulKV - param serverIp = $serverIp"

$ErrorActionPreference = 'Stop'

$commonParameterSwitches =
    @{
        Verbose = $PSBoundParameters.ContainsKey('Verbose');
        Debug = $false;
        ErrorAction = 'Stop'
    }

# ------------------ START FUNCTIONS ----------------------------

function Set-ConsulKV
{
    [CmdletBinding()]
    param(
        [string] $consulPath,
        [string] $consulUrl
    )

    Write-Verbose "Set-ConsulKV - param consulPath = $consulPath"
    Write-Verbose "Set-ConsulKV - param consulUrl = $consulUrl"

    $ErrorActionPreference = 'Stop'

    $commonParameterSwitches =
        @{
            Verbose = $PSBoundParameters.ContainsKey('Verbose');
            Debug = $false;
            ErrorAction = 'Stop'
        }

    $kvDirectory = $PSScriptRoot
    $kvFiles = Get-ChildItem -Path $kvDirectory\* -Include *.yaml -Recurse
    foreach($kvFile in $kvFiles)
    {
        Write-Output "Processing $($kvFile.FullName) ..."
        $yaml = ConvertFrom-Yaml -Yaml (Get-Content $kvFile.FullName | Out-String)

        # The Yaml object is a hashtable, that contains a single item with 'config' as key.
        # The value is a list of hashtables, each of which store two values, one for the 'key'
        # entry and one for the 'value' or 'file' entries.
        foreach($entry in $yaml['config'])
        {
            $key = $entry['key']
            if ($entry.ContainsKey('file'))
            {
                $path = Join-Path (Split-Path -Parent -Path $kvFile.FullName) $entry['file']
                $value = Get-Content -Path $path | Out-String
            }
            else
            {
                $value = $entry['value']
            }

            Write-Output "    Setting: $key to $value"
            Start-Process `
                -FilePath $consulPath `
                -ArgumentList "kv put -http-addr=$consulUrl $key `"$value`"" `
                -NoNewWindow `
                -Wait
        }
    }
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

    $consulDirectory = Join-Path $tempPath 'consul'
    if (($consulPath -eq $null) -or ($consulPath -eq '') -or (-not (Test-Path $consulPath)))
    {
        Add-Type -AssemblyName System.IO.Compression.FileSystem

        $url = 'https://releases.hashicorp.com/consul/1.0.6/consul_1.0.6_windows_amd64.zip'
        $output = Join-Path $tempPath 'consul.zip'
        try
        {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls
            (New-Object System.Net.WebClient).DownloadFile($url, $output)
        }
        catch
        {
            Write-Error $_.Exception.ToString()
        }

        [System.IO.Compression.ZipFile]::ExtractToDirectory($output, $consulDirectory)
        $consulPath = Join-Path $consulDirectory 'consul.exe'
    }

    $consulUrl = "http://$($serverIp):$($port)"

    Write-Output "Setting consul k-v's ..."
    Set-ConsulKV `
        -consulPath $consulPath `
        -consulUrl $consulUrl `
        @commonParameterSwitches
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
