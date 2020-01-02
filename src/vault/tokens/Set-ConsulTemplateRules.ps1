[CmdletBinding()]
param(
    [string] $vaultPath = 'vault',
    [string] $vaultServerAddress
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers.ps1')

# Linux - Default
$defaultLinuxPolicies = 'default' `
    + ',secret.services.metrics.users.write' `
    + ',secret.services.queue.users.logs.syslog'
$createRole = @(
    'auth/token/roles/role.system.linux',
    'period=1h',
    'orphan=true',
    "allowed_policies=$defaultLinuxPolicies"
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole

# Linux - Nexus artefacts
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

# Linux - Jenkins controller
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

# Linux - Grafana
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

# Linux - SNMP trap
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

# Windows - Default
$defaultWindowsPolicies = 'default' `
    + ',secret.services.metrics.users.write' `
    + ',secret.services.queue.users.logs.eventlog' `
    + ',secret.services.queue.users.logs.filelog'
$createRole = @(
    'auth/token/roles/role.system.windows',
    'period=1h',
    'orphan=true',
    "allowed_policies=$defaultWindowsPolicies"
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $createRole

# Windows - Build agent
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
