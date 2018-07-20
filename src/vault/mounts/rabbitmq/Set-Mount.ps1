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
