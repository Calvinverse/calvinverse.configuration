[CmdletBinding()]
param(
    [string] $vaultPath = 'vault',
    [string] $vaultServerAddress
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'helpers.ps1')

$args = @(
    'approle'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'auth enable' `
    -arguments $args
