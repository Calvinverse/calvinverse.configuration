[CmdletBinding()]
param(
    [string] $vaultPath,
    [string] $serverAddress,
    [string] $consulDomain = 'consulverse',
    [string] $rabbitUser = 'user.vault',
    [string] $rabbitPassword = ''
)

& $vaultPath `
    secrets `
    -address=$($serverAddress) `
    -tls-skip-verify=1 `
    enable `
    rabbitmq

& $vaultPath `
    write `
    -address=$($serverAddress) `
    -tls-skip-verify=1 `
    rabbitmq/config/connection `
    connection_uri="http://http.queue.service.$($consulDomain):15672" `
    username="$($rabbitUser)" `
    password="$($rabbitPassword)"

& $vaultPath `
    write `
    -address=$($serverAddress) `
    -tls-skip-verify=1 `
    rabbitmq/config/lease `
    ttl=3600 `
    max_ttl=86400

& $vaultPath `
    write `
    -address=$($serverAddress) `
    -tls-skip-verify=1 `
    rabbitmq/roles/logs.syslog.writer `
    vhosts='{"logs":{"write":".*"}}'
