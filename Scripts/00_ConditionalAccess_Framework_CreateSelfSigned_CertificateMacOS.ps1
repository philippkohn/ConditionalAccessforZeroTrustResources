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
File Name      : 00_ConditionalAccess_Framework_CreateSelfSigned_CertificateMacOS.ps1
Author         : Philipp Kohn, Assisted by OpenAI's ChatGPT
Prerequisite   : PowerShell Core 7.0 and above, OpenSSL installed.
Copyright 2025 : cloudcopilot.de

Change Log
----------
Date       Version   Author          Description
--------   -------   ------          -----------
14/08/23   1.0       Philipp Kohn    Initial creation with assistance from OpenAI's ChatGPT.
14/08/23   1.1       Philipp Kohn    Changed the common Name to the Tenant Name
26/03/25   1.2       Philipp Kohn    Updated script for macOS compatibility, replaced Windows certificate commands with OpenSSL.
#>

# Prompt user for Microsoft Entra Default Tenant Name
Write-Host "Prompting for Microsoft Entra Default Tenant Name..." -ForegroundColor 'Cyan'
$dnsName = Read-Host "Your Microsoft Entra Default Tenant Name (Example: yourcompany.onmicrosoft.com)"

# Define certificate details
$certName = "00_ConditionalAccess_Framework_$($dnsName)_Certificate"
$certPassword = "YourSecurePassword" # Change this to a secure password
$certValidityDays = 90

# Define file paths
$certPath = "./$certName.pem"
$privateKeyPath = "./$certName.key"
$pfxPath = "./$certName.pfx"

# Generate a new private key
Write-Host "Generating private key..." -ForegroundColor 'Magenta'
openssl genpkey -algorithm RSA -out $privateKeyPath

# Create a self-signed certificate
Write-Host "Creating self-signed certificate..." -ForegroundColor 'Magenta'
openssl req -new -x509 -key $privateKeyPath -out $certPath -days $certValidityDays -subj "/CN=$dnsName, GivenName=Philipp, Surname=Kohn, E=webmaster@cloudcopilot.de"

# Convert to PFX for Graph authentication
Write-Host "Converting certificate to PFX format..." -ForegroundColor 'Magenta'
openssl pkcs12 -export -out $pfxPath -inkey $privateKeyPath -in $certPath -password pass:$certPassword

Write-Output "Certificate and key files generated:"
Write-Output "PEM Certificate: $certPath"
Write-Output "Private Key: $privateKeyPath"
Write-Output "PFX File (for Graph Authentication): $pfxPath"