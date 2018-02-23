[CmdletBinding()]
param(
    [string] $vaultPath,
    [string] $serverAddress
)

$ErrorActionPreference = 'Stop'

& $vaultPath `
    write `
    -address=$($serverAddress) `
    -tls-skip-verify=1 `
    auth/token/roles/system.shared `
    period=1h `
    allowed_policies="default,logs.syslog.writer,metrics.http.writer"

& $vaultPath `
    write `
    -address=$($serverAddress) `
    -tls-skip-verify=1 `
    -f `
    auth/token/create/system.shared
