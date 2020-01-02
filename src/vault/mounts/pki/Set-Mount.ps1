[CmdletBinding()]
param(
    [string] $vaultPath = 'vault',
    [string] $vaultServerAddress
)

$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'helpers.ps1')

$name = 'pki-ca'
$enablePki = @(
    "-path=$($name)",
    'pki'
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'secrets enable' `
    -arguments $enablePki

# Max lease period is five years
$setPki = @(
    "-max-lease-ttl=43800h",
    $name
)
Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'secrets tune' `
    -arguments $setPki

$getCsr = @(
    "$($name)/intermediate/generate/internal",
    "common_name=`"vault.ad.calvinverse.net intermediate`"",
    "ttl=43800h",
    "add_basic_constraints=true"
)
$output = Invoke-Vault `
    -vaultPath $vaultPath `
    -vaultServerAddress $vaultServerAddress `
    -command 'write' `
    -arguments $getCsr

$csr = $output[2].Substring($output[2].Indexof('csr'))

# Write the csr to file and push it to the certificate authority for signing
# sign it with
#
# certreq -submit -attrib "CertificateTemplate:SubCA" vault.req vault.cer

#
# Import the signed vault.cer file with
# vault write pki-ca/intermediate/set-signed certificate=@<CERT_FILE_PATH>