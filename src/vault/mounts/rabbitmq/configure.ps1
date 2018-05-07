[CmdletBinding()]
param(
    [string] $vaultPath,
    [string] $vaultServerAddress,
    [string] $consulDomain = 'consulverse',
    [string] $rabbitUser = 'user.vault',
    [string] $rabbitPassword = ''
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'helpers.ps1')

<#
$enableRabbitMq = @(
    'rabbitmq'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'secrets enable' `
    -arguments $enableRabbitMq

$configureRabbitMq = @(
    'rabbitmq/config/connection',
    "connection_uri=`"http://http.queue.service.$($consulDomain):15672`"",
    "username=`"$($rabbitUser)`"",
    "password=`"$($rabbitPassword)`""
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $configureRabbitMq

$ttlRabbitMq = @(
    'rabbitmq/config/lease',
    'ttl=3600',
    "max_ttl=86400"
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $ttlRabbitMq
#>
try
{
    $yamlModule = 'powershell-yaml'
    if (-not (Get-Module -ListAvailable -Name $yamlModule))
    {
        Install-Module -Name $yamlModule -Scope CurrentUser
    }

    if (-not (Get-module -Name $yamlModule))
    {
        Import-Module -Name $yamlModule -Scope Local
    }

    $kvFiles = Get-ChildItem -Path "$($PSScriptRoot)\*" -Recurse -Include *.yaml

    $webClient = New-Object System.Net.WebClient
    try
    {
        $kvFiles = Get-ChildItem -Path "$($PSScriptRoot)\*" -Recurse -Include *.yaml
        foreach($kvFile in $kvFiles)
        {
            Write-Output "Processing $($kvFile.FullName) ..."
            $yaml = ConvertFrom-Yaml -Yaml (Get-Content $kvFile.FullName | Out-String)

            # The Yaml object is a hashtable, that contains a single item with 'roles' as key.
            # The value is a list of hashtables, each of which store two values, one for the 'key'
            # entry and one for the 'value' or 'file' entries.
            foreach($entry in $yaml.roles)
            {
                $key = $entry['key']
                if ($entry.ContainsKey('file'))
                {
                    $path = Join-Path (Split-Path -Parent -Path $kvFile.FullName) $entry['file']
                    $value = Get-Content -Path $path | Out-String
                    $bytes = [System.Text.Encoding]::UTF8.GetBytes($value)
                }
                else
                {
                    $value = $entry['value'].ToString()
                    $bytes = [System.Text.Encoding]::UTF8.GetBytes($value)
                }

                Write-Output "Writing k-v with key: $($key) - value: $($value) ... "

                $url = "$($vaultServerAddress)/v1/kv/$($key)"
                $responseBytes = $webClient.UploadData($url, "PUT", $bytes)
                $response = [System.Text.Encoding]::ASCII.GetString($responseBytes)
                Write-Output "Wrote k-v with key: $($key) - value: $($value). Response: $($response)"
            }
        }
    }
    finally
    {
        $webClient.Dispose()
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
