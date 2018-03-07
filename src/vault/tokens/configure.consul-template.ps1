[CmdletBinding()]
param(
    [string] $vaultPath,
    [string] $vaultServerAddress
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers.ps1')

$createRole = @(
    'auth/token/roles/system.shared',
    'period=1h',
    'allowed_policies="default,logs.syslog.writer,metrics.http.writer"'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole
