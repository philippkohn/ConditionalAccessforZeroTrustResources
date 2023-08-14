<#
.SYNOPSIS
This script creates a self-signed certificate and exports the public and private keys to files.

.DESCRIPTION
The script creates a self-signed certificate intended for use with Microsoft Graph PowerShell SDK Authentication. 
When working with the Microsoft Graph PowerShell SDK, a certificate can be used as a secure method for application authentication 
instead of a client secret. This script facilitates the creation and export of such a certificate, allowing users to integrate 
certificate-based authentication into their Microsoft Graph workflows.

.OUTPUTS
The script outputs the paths to the exported public and private key files.

.NOTES
File Name      : 00_ConditionalAccess_Framework_CreateSelfSigned_Certificate.ps1
Author         : Philipp Kohn, Assisted by OpenAI's ChatGPT
Prerequisite   : Windows PowerShell 5.1 or PowerShell Core 7.0 and above. PKI module.
Copyright 2023 : cloudcopilot.de

Change Log
----------
Date       Version   Author          Description
--------   -------   ------          -----------
14/08/23   1.0       Philipp Kohn    Initial creation with assistance from OpenAI's ChatGPT.
#>


# Prompt user for DnsName
Write-Host "Prompting for Microsoft Entra Default Tenant Name..." -ForegroundColor 'Cyan'
$dnsName = Read-Host "Your Microsoft Entra Default Tenant Name (Example: yourcompany.onmicrosoft.com)"

# Define parameters for the certificate
$certParams = @{
    FriendlyName      = 'Cloudcopilot.de - GraphPowerShellSDK - CA Policy Management'
    CertStoreLocation = 'Cert:\CurrentUser\My'
    NotAfter          = (Get-Date).AddYears(1)
    NotBefore         = Get-Date
    DnsName           = $dnsName
    #KeyProtection     = 'Protect'
    Subject           = "GivenName=Philipp, Surname=Kohn, E=webmaster@cloudcopilot.de"
}

# Create the self-signed certificate
Write-Host "Creating self-signed certificate..." -ForegroundColor 'Magenta'
$cert = New-SelfSignedCertificate @certParams

# Export the public key to a .cer file
$publicKeyPath = Join-Path -Path $PSScriptRoot -ChildPath "CA_PolicyManagement_Authentication_publicKey.cer"
Write-Host "Exporting public key to $publicKeyPath..." -ForegroundColor 'Cyan'
Export-Certificate -Cert $cert -FilePath $publicKeyPath

# Prompt the user for a password for the private key
Write-Host "Prompting for a password for the private key..." -ForegroundColor 'Magenta'
$password = Read-Host "Enter a password for the private key" -AsSecureString

# Export the private key to a .pfx file
$privateKeyPath = Join-Path -Path $PSScriptRoot -ChildPath "CA_PolicyManagement_Authentication_privateKey.pfx"
Write-Host "Exporting private key to $privateKeyPath..." -ForegroundColor 'Cyan'
Export-PfxCertificate -Cert $cert -FilePath $privateKeyPath -Password $password

# Output the paths to the exported files
Write-Host "`nSummary:" -ForegroundColor 'Cyan'
Write-Host "--------"
Write-Host "Public key saved to: $publicKeyPath" -ForegroundColor 'Magenta'
Write-Host "Private key saved to: $privateKeyPath" -ForegroundColor 'Cyan'
Write-Host "Script completed successfully!"