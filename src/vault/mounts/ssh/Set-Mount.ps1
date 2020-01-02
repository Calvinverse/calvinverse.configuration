[CmdletBinding()]
param(
    [string] $vaultPath = 'vault',
    [string] $vaultServerAddress,
    [string] $consulPort = '8500',
    [string] $consulServerAddress = $( throw 'Please specify the IP address for the consul server' )
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'helpers.ps1')

$name = 'ssh-ca'
$enableSshClientSigning = @(
    "-path=$($name)",
    'ssh'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'secrets enable' `
    -arguments $enableSshClientSigning




# Ask Vault to generate a PKI cert that can be used for signing








$setSshCA = @(
    "$($name)/config/ca",
    "private_key=`"PRIVATE_KEY_HERE`"",
    "public_key=`"PUBLIC_KEY_HERE`""
)
$output = Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $setSshCA

$publicKey = $output[2].Substring($output[2].Indexof('ssh-rsa'))

# Write token for machine to consul kv
# auth/services/templates/<MACHINE_NAME>/secrets
$key = "auth/ssh/ca/public"
$value = $publicKey

Write-Output "Writing k-v with key: $($key) - value: $($value) ... "

$webClient = New-Object System.Net.WebClient
try {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($value)

    $url = "http://$($consulServerAddress):$($consulPort)/v1/kv/$($key)"
    $responseBytes = $webClient.UploadData($url, "PUT", $bytes)
    $response = [System.Text.Encoding]::ASCII.GetString($responseBytes)
    Write-Output "Wrote k-v with key: $($key) - value: $($value). Response: $($response)"
}
finally {
    $webClient.Dispose()
}
