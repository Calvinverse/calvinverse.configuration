[CmdletBinding()]
param(
    [string] $vaultPath,
    [string] $vaultServerAddress
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers.ps1')

$createRole = @(
    'auth/token/roles/role.system.logsandmetrics',
    'period=1h',
    'orphan=true',
    'allowed_policies="default,rabbitmq.creds.write.vhost.logs.syslog,secret.write.metrics.http"'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole

$createRole = @(
    'auth/token/roles/role.artefacts.http',
    'period=1h',
    'orphan=true',
    'allowed_policies="default,rabbitmq.creds.write.vhost.logs.syslog,secret.environment.directory.bind"'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole

$createRole = @(
    'auth/token/roles/role.build.master',
    'period=1h',
    'orphan=true',
    'allowed_policies="default,rabbitmq.creds.write.vhost.logs.syslog,secret.write.metrics.http,rabbitmq.creds.read.vhost.builds,secret.environment.directory.bind"'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole

$createRole = @(
    'auth/token/roles/role.metrics.dashboards',
    'period=1h',
    'orphan=true',
    'allowed_policies="default,rabbitmq.creds.write.vhost.logs.syslog,secret.write.metrics.http,secret.environment.directory.bind"'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole
