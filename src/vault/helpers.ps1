function Invoke-Vault
{
    [CmdletBinding()]
    param(
        [string] $vaultPath,
        [string] $vaultServerAddress,
        [string] $command,
        [string[]] $arguments
    )

    $argument = ''
    if ($arguments -ne $null)
    {
        foreach($arg in $arguments)
        {
            $argument += " $arg"
        }
    }

    $expression = "& `"$vaultPath`" $command -address=$($vaultServerAddress) -tls-skip-verify $argument"
    Write-Verbose "Invoking vault with: $($expression)"
    Invoke-Expression -Command $expression
}
