[CmdletBinding()]
param(
    [string] $vaultPath,
    [string] $vaultServerAddress
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers.ps1')

$defaultLinuxPolicies = 'default' `
    + ',rabbitmq.creds.write.vhost.logs.syslog' `
    + ',secret.write.metrics.http'
$createRole = @(
    'auth/token/roles/role.system.syslogandmetrics',
    'period=1h',
    'orphan=true',
    "allowed_policies=$defaultLinuxPolicies"
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole

$defaultWindowsPolicies = 'default' `
    + ',rabbitmq.creds.write.vhost.logs.file' `
    + ',secret.write.metrics.http'
$createRole = @(
    'auth/token/roles/role.system.filelogandmetrics',
    'period=1h',
    'orphan=true',
    "allowed_policies=$defaultWindowsPolicies"
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole

$httpArtefactRules = $defaultLinuxPolicies `
    + ',secret.environment.directory.bind'
$createRole = @(
    'auth/token/roles/role.artefacts.http',
    'period=1h',
    'orphan=true',
    "allowed_policies=$httpArtefactRules"
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole

$masterBuildRules = $defaultLinuxPolicies `
    + ',rabbitmq.creds.readwrite.vhost.build.trigger' `
    + ',secret.environment.directory.bind' `
    + ',secret.projects.nbuildkit'
$createRole = @(
    'auth/token/roles/role.build.master',
    'period=1h',
    'orphan=true',
    "allowed_policies=$masterBuildRules"
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole

$windowsBuildAgentRules = $defaultWindowsPolicies `
    + ',secret.environment.directory.users.build.agent'
$createRole = @(
    'auth/token/roles/role.build.agent.windows',
    'period=1h',
    'orphan=true',
    "allowed_policies=$windowsBuildAgentRules"
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole

$dashboardMetricsRules = $defaultLinuxPolicies `
    + ',secret.environment.directory.bind'
$createRole = @(
    'auth/token/roles/role.metrics.dashboards',
    'period=1h',
    'orphan=true',
    "allowed_policies=$dashboardMetricsRules"
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole

$snmpMetricsRules = $defaultLinuxPolicies `
    + ',secret.environment.infrastructure.snmp'
$createRole = @(
    'auth/token/roles/role.metrics.snmp',
    'period=1h',
    'orphan=true',
    "allowed_policies=$snmpMetricsRules"
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole
