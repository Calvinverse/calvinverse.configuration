[CmdletBinding()]
param(
    [string] $vaultPath = 'vault',
    [string] $vaultServerAddress,
    [string] $consulDomain = 'consulverse',
    [string] $elasticsearchUser = 'user.vault',
    [string] $elasticsearchPassword = ''
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'helpers.ps1')

$enableElasticsearch = @(
    '-path=elasticsearch',
    'database'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'secrets enable' `
    -arguments $enableElasticsearch

$configureElasticsearch = @(
    'elasticsearch/config/my-index',
    "plugin_name=`"elasticsearch-database-plugin`"",
    "host=`"http.documents.service.$($consulDomain)`"",
    "username=`"$($elasticsearchUser)`"",
    "password=`"$($elasticsearchPassword)`""
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $configureElasticsearch
