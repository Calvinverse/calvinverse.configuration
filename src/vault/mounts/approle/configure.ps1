[CmdletBinding()]
param(
    [string] $vaultPath,
    [string] $serverAddress
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'helpers.ps1')

$args = @(
    'approle'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -serverAddress $serverAddress `
    -command 'auth enable' `
    -arguments $args
