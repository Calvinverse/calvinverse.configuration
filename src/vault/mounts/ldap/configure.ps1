[CmdletBinding()]
param(
    [string] $vaultPath,
    [string] $vaultServerAddress,
    [string] $ldapServerNameOrIp,
    [string] $userDn = 'OU=People,OU=Calvinverse Users,DC=ad,DC=calvinverse,DC=net',
    [string] $groupDn = 'OU=Users,OU=Calvinverse Groups,DC=ad,DC=calvinverse,DC=net',
    [string] $bindDn = 'CN=AD Check,OU=Services,OU=Calvinverse Users,DC=ad,DC=calvinverse,DC=net',
    [string] $bindPassword = ''
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'helpers.ps1')

$enableLdap = @(
    'ldap'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'auth enable' `
    -arguments $enableLdap

$ldapConfigArguments = @(
    'auth/ldap/config',
    'userattr=sAMAccountName',
    "url=ldap://$($ldapServerNameOrIp)",
    "userdn=`"$($userDn)`"",
    "groupdn=`"$($groupDn)`"",
    'groupfilter="(&(objectClass=group)(member:1.2.840.113556.1.4.1941:={{.UserDN}}))"',
    'groupattr=cn',
    "binddn=`"$($bindDn)`"",
    "bindpass=`"$($bindPassword)`"",
    'insecure_tls=true',
    'starttls=false'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $ldapConfigArguments

$ldapAdminArguments = @(
    'auth/ldap/groups/"Infrastructure Administrators"',
    'policies=admin'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $ldapAdminArguments
