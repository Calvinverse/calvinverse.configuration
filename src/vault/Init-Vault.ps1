[CmdletBinding()]
param(
    [string] $vaultPath,
    [string] $serverAddress
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers.ps1')

Invoke-Vault `
    -vaultPath $vaultPath `
    -serverAddress $serverAddress `
    -command 'operator init'
