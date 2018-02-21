[CmdletBinding()]
param(
    [string] $vaultPath,
    [string] $serverAddress,
    [string] $ldapServerNameOrIp,
    [string] $userDn = 'OU=People,OU=Calvinverse Users,DC=ad,DC=calvinverse,DC=net',
    [string] $groupDn = 'OU=Users,OU=Calvinverse Groups,DC=ad,DC=calvinverse,DC=net',
    [string] $upnDomain = 'ad.calvinverse.net',
    [string] $bindDn = 'CN=AD Check,OU=Services,OU=Calvinverse Users,DC=ad,DC=calvinverse,DC=net',
    [string] $bindPassword = ''
)

& $vaultPath `
    write `
    -address=$($serverAddress) `
    -tls-skip-verify `
    auth/ldap/config `
    userattr=sAMAccountName `
    url="ldap://$($ldapServerNameOrIp)" `
    userdn="$($userDn)" `
    groupdn="$($groupDn)" `
    groupfilter="(&(objectClass=group)(member:1.2.840.113556.1.4.1941:={{.UserDN}}))" `
    groupattr="cn" `
    upndomain="$($upnDomain)" `
    binddn="$($bindDn)" `
    bindpass="$($bindPassword)" `
    insecure_tls=true `
    starttls=false
