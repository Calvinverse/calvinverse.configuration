[CmdletBinding()]
param(
    [string] $vaultPath = 'vault',
    [string] $vaultServerAddress
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'helpers.ps1')

Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'operator init'
