function Invoke-Vault
{
    [CmdletBinding()]
    param(
        [string] $vaultPath,
        [string] $serverAddress,
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

    $expression = "& `"$vaultPath`" $command -address=$($serverAddress) -tls-skip-verify $argument"
    Invoke-Expression -Command $expression
}
