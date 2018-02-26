[CmdletBinding()]
param(
    [string] $vaultPath,
    [string] $serverAddress
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'helpers.ps1')

Invoke-Vault `
    -vaultPath $vaultPath `
    -serverAddress $serverAddress `
    -command 'operator init'
