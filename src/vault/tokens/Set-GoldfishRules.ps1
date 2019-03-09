[CmdletBinding()]
param(
    [string] $vaultPath = 'vault',
    [string] $vaultServerAddress
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers.ps1')

$createApprole = @(
    'auth/approle/role/goldfish',
    'role_name=goldfish',
    'policies=default,approle.goldfish',
    'secret_id_num_uses=1',
    'secret_id_ttl=5m',
    'period=24h',
    'token_ttl=0',
    'token_max_ttl=0'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createApprole

$createRoleId = @(
    'auth/approle/role/goldfish/role-id',
    'role_id=goldfish'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRoleId

$createSecretStore = @(
    'secret/goldfish',
    'DefaultSecretPath="secret/"',
    'UserTransitKey="usertransit"',
    'BulletinPath="secret/bulletins/"'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createSecretStore
