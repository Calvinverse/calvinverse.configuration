[CmdletBinding()]
param(
    [string] $vaultPath = 'vault',
    [string] $vaultServerAddress,
    [string] $mountName = 'ssh'
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
            if (-not $entry.ContainsKey('file'))
            {
                Write-Warning "Entry with key: $name is not a file entry. Non-File entries are not allowed for SSH roles. This entry will be skipped."
                continue
            }

            $category = $entry['category']
            $path = Join-Path (Split-Path -Parent -Path $roleFile.FullName) $entry['file']

            $url = "$($vaultServerAddress)/v1/$($mountName)-$($mountCategory)/roles/$($name)"
            Write-Output "Writing SSH role with name: $($name) - role: $($roleJson) to $($url) ... "

            $setRole = @(
                "$($mountName)-$($category)/roles/$($name)",
                "@$($path)"
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
