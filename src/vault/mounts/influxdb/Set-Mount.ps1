[CmdletBinding()]
param(
    [string] $vaultPath = 'vault',
    [string] $vaultServerAddress,
    [string] $consulDomain = 'consulverse',
    [string] $influxdbUser = 'user.vault',
    [string] $influxdbPassword = ''
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'helpers.ps1')
$enableInfluxDb = @(
    '-path=influxdb',
    'database'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'secrets enable' `
    -arguments $enableInfluxDb

$configureInfluxDbSystem = @(
    'influxdb/config/system',
    "plugin_name=`"influxdb-database-plugin`"",
    "host=`"http.metrics.service.$($consulDomain)`"",
    "username=`"$($influxdbUser)`"",
    "password=`"$($influxdbPassword)`"",
    "allowed_roles=`"*`""
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $configureInfluxDbSystem

$configureInfluxDbServices = @(
    'influxdb/config/services',
    "plugin_name=`"influxdb-database-plugin`"",
    "host=`"http.metrics.service.$($consulDomain)`"",
    "username=`"$($influxdbUser)`"",
    "password=`"$($influxdbPassword)`"",
    "allowed_roles=`"*`""
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $configureInfluxDbServices
