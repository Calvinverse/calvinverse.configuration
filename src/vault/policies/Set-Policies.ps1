[CmdletBinding()]
param(
    [string] $vaultPath,
    [string] $serverAddress
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers.ps1')

$files = Get-ChildItem -Path "$($PSScriptRoot)\*" -Include *.hcl
foreach($file in $files)
{
    $fileName = $file.Name
    $policyName = $file.BaseName

    $arguments = @(
        "sys/policy/$($policyName)",
        "policy=@$($fileName)"
    )

    Write-Output "Writing policy $($policyName) from $($fileName)"
    Invoke-Vault `
        -vaultPath $vaultPath `
        -serverAddress $serverAddress `
        -command 'write' `
        -arguments $arguments
}
