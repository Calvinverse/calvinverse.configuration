[CmdletBinding()]
param(
    [string] $vaultPath = 'vault',
    [string] $vaultServerAddress
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
        "policy=@$(Join-Path $PSScriptRoot $fileName)"
    )

    Write-Output "Writing policy $($policyName) from $($fileName)"
    Invoke-Vault `
        -vaultPath $vaultPath `
        -vaultServerAddress $vaultServerAddress `
        -command 'write' `
        -arguments $arguments
}
