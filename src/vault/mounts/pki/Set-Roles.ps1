[CmdletBinding()]
param(
    [string] $vaultPath = 'vault',
    [string] $vaultServerAddress,
    [string] $mountName = 'pki-ca'
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'helpers.ps1')

try
{
    $yamlModule = 'powershell-yaml'
    if (-not (Get-Module -ListAvailable -Name $yamlModule))
    {
        Install-Module -Name $yamlModule -Scope CurrentUser
    }

    if (-not (Get-module -Name $yamlModule))
    {
        Import-Module -Name $yamlModule -Scope Local
    }

    $roleFiles = Get-ChildItem -Path "$($PSScriptRoot)\*" -Recurse -Include *.yaml
    foreach($roleFile in $roleFiles)
    {
        Write-Output "Processing $($roleFile.FullName) ..."
        $yaml = ConvertFrom-Yaml -Yaml (Get-Content $roleFile.FullName | Out-String)

        # The Yaml object is a hashtable, that contains a single item with 'roles' as key.
        # The value is a list of hashtables, each of which store two values, one for the 'key'
        # entry and one for the 'value' or 'file' entries.
        foreach($entry in $yaml.roles)
        {
            $name = $entry['name']
            if ($entry.ContainsKey('file'))
            {
                $path = Join-Path (Split-Path -Parent -Path $roleFile.FullName) $entry['file']
                $roleJson = ConvertFrom-Json (Get-Content -Path $path | Out-String)
                $role = $roleJson.vhosts

            }
            else
            {
                $role = $entry['role'].ToString()
            }

            $url = "$($vaultServerAddress)/v1/$($mountName)/roles/$($name)"
            Write-Output "Writing PKI role with name: $($name) - role: $($role) to $($url) ... "

            $setRole = @(
                "$mountName/roles/$($name)",
                "vhosts=`'$($role)`'"
            )
            Invoke-Vault `
                -vaultPath $vaultPath `
                -vaultServerAddress $vaultServerAddress `
                -command 'write' `
                -arguments $setRole
        }
    }
}
catch
{
    $currentErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    try
    {
        Write-Error $errorRecord.Exception
        Write-Error $errorRecord.ScriptStackTrace
        Write-Error $errorRecord.InvocationInfo.PositionMessage
    }
    finally
    {
        $ErrorActionPreference = $currentErrorActionPreference
    }

    # rethrow the error
    throw $_.Exception
}
