[CmdletBinding()]
param(
    [string] $vaultPath,
    [string] $vaultServerAddress
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers.ps1')

$createRole = @(
    'auth/token/roles/system.logsandmetrics',
    'period=1h',
    'allowed_policies="default,logs.syslog.writer,metrics.http.writer"'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole

$createRole = @(
    'auth/token/roles/build.master',
    'period=1h',
    'allowed_policies="default,logs.syslog.writer,metrics.http.writer,builds.queue.reader,environment.directory.bind"'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole
