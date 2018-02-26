[CmdletBinding()]
param(
    [string] $vaultPath,
    [string] $serverAddress
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
    -serverAddress $serverAddress `
    -command 'write' `
    -arguments $createRole

$createToken = @(
    '-force',
    'auth/token/create/system.shared'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -serverAddress $serverAddress `
    -command 'write' `
    -arguments $createToken
