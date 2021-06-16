[CmdletBinding()]
param(
    [string] $vaultPath = 'vault',
    [string] $vaultServerAddress,
    [string] $consulPort = '8500',
    [string] $consulServerAddress = $( throw 'Please specify the IP address for the consul server' )
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'helpers.ps1')

# -------------- Functions

function New-SshMount {
    [CmdletBinding()]
    param(
        [string] $name,
        [string] $vaultPath = 'vault',
        [string] $vaultServerAddress
    )

    $enableSshClientSigning = @(
        "-path=$($name)",
        'ssh'
    )
    Invoke-Vault `
        -vaultPath $vaultPath `
        -vaultServerAddress $vaultServerAddress `
        -command 'secrets enable' `
        -arguments $enableSshClientSigning
}

function Set-ClientCertificate {
    [CmdletBinding()]
    param(
        [string] $vaultPath,
        [string] $vaultServerAddress,
        [string] $consulPort,
        [string] $consulServerAddress
    )

    $mount = 'ssh'
    $category = 'client'
    $name = "$($mount)-$($category)"
    New-SshMount `
        -name $name `
        -vaultPath $vaultPath `
        -vaultServerAddress $vaultServerAddress

    # Generate the key
    $setSshCA = @(
        "$($name)/config/ca",
        "generate_signing_key=true"
    )
    $output = Invoke-Vault `
        -vaultPath $vaultPath `
        -vaultServerAddress $vaultServerAddress `
        -command 'write' `
        -arguments $setSshCA

    $publicKey = $output[2].Substring($output[2].Indexof('ssh-rsa'))

    # Write token for machine to consul kv
    # auth/services/templates/<MACHINE_NAME>/secrets
    $key = "auth/$($mount)/$($category)/ca/public"
    $value = $publicKey

    # Set the public key in Consul
    Set-ConsulKey `
        -key $key `
        -value $value `
        -consulPort $consulPort `
        -consulServerAddress $consulServerAddress
}

function Set-ConsulKey {
    [CmdletBinding()]
    param(
        [string] $key,
        [string] $value,
        [string] $consulPort,
        [string] $consulServerAddress
    )

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
}

function Set-HostCertificate {
    [CmdletBinding()]
    param(
        [string] $vaultPath,
        [string] $vaultServerAddress,
        [string] $consulPort,
        [string] $consulServerAddress
    )

    $mount = 'ssh'
    $category = 'host'
    $name = "$($mount)-$($category)"
    New-SshMount `
        -name $name `
        -vaultPath $vaultPath `
        -vaultServerAddress $vaultServerAddress

    # Generate the key
    $setSshCA = @(
        "$($name)/config/ca",
        "generate_signing_key=true"
    )
    $output = Invoke-Vault `
        -vaultPath $vaultPath `
        -vaultServerAddress $vaultServerAddress `
        -command 'write' `
        -arguments $setSshCA

    # Generate the key
    $tuneSshCA = @(
        "-max-lease-ttl=87600h",
        $name
    )
    $output = Invoke-Vault `
        -vaultPath $vaultPath `
        -vaultServerAddress $vaultServerAddress `
        -command 'secrets tune' `
        -arguments $tuneSshCA

    $publicKey = $output[2].Substring($output[2].Indexof('ssh-rsa'))

    # Write token for machine to consul kv
    # auth/services/templates/<MACHINE_NAME>/secrets
    $key = "auth/$($mount)/$($category)/ca/public"
    $value = $publicKey

    # Set the public key in Consul
    Set-ConsulKey `
        -key $key `
        -value $value `
        -consulPort $consulPort `
        -consulServerAddress $consulServerAddress
}

# ------------------------

Set-ClientCertificate `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -consulPort $consulPort `
    -consulServerAddress $consulServerAddress

Set-HostCertificate `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -consulPort $consulPort `
    -consulServerAddress $consulServerAddress
