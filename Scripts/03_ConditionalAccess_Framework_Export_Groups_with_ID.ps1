<#
.SYNOPSIS
Connects to Microsoft Graph API and exports a list of groups with a specific prefix to a CSV file.

.DESCRIPTION
- This script initiates by checking the PowerShell version, ensuring it's 7 or newer. 
- It then disconnects from any active Microsoft Graph API sessions and establishes a new connection using specified environment variables and a certificate thumbprint. 
- The script proceeds to filter groups that start with 'CA-' using the Get-MgGroup cmdlet and selects their DisplayName, Description, and Id properties. 
- Finally, the results are exported to a specified CSV file.

.PARAMETER
OutputPath: Specifies the path where the CSV file will be saved.

.OUTPUTS
A CSV file containing information about the filtered groups.

.NOTES
File Name      : 03_ConditionalAccess_Framework_Export_Groups_with_ID.ps1
Author         : Philipp Kohn, Assisted by OpenAI's ChatGPT
Prerequisite   : PowerShell 7.x or newer. Microsoft Graph PowerShell SDK.
Copyright 2023 : cloudcopilot.de

Change Log
----------
Date       Version   Author         Description
--------   -------   ------         -----------
15/07/23   1.0       Philipp Kohn   Initial version.
14/08/23   1.1       Philipp Kohn   Changed Authentication to Certificate-based Auth, Optimized user prompts and environment variable clean-up.
#>

# Check PowerShell Version
Write-Host "Check if running PowerShell Version 7.x" -ForegroundColor 'Cyan'
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Throw "This script requires PowerShell 7 or a newer version."
}

# Try Discconnect Microsoft Graph API
Write-Host "Disconnect from existing Microsoft Graph API Sessions" -ForegroundColor Cyan
try{Disconnect-MgGraph -ErrorAction SilentlyContinue}catch{}

# Add environment variables to be used by Connect-MgGraph
$env:AZURE_CLIENT_ID = "YOUR Client ID from your App Registration in Microsoft Entra"
$env:AZURE_TENANT_ID = "YOUR Tenant ID"

# Add environment variable with the Thumbprint of your Certificate
$Certificate = "The Tumbprint of your Certificate"

# Connect to Microsoft Graph PowerShell SDK
Connect-MgGraph -ClientId $env:AZURE_CLIENT_ID -TenantId $env:AZURE_TENANT_ID -CertificateThumbprint $Certificate

# Connection Infos for Microsoft Graph PowerShell SDK Connection
Write-Host "Getting the built-in onmicrosoft.com domain name of the tenant..." -ForegroundColor Magenta
$tenantName = (Get-MgOrganization).VerifiedDomains | Where-Object {$_.IsInitial -eq $true} | Select-Object -ExpandProperty Name
$AppRegistration = (Get-MgContext | Select-Object -ExpandProperty AppName)
$Scopes = (Get-MgContext | Select-Object -ExpandProperty Scopes)
Write-Host "Tenant: $tenantName" -ForegroundColor 'Cyan'
Write-Host "AppRegistration: $AppRegistration" -ForegroundColor 'Magenta'
Write-Host "Scopes: $Scopes" -ForegroundColor 'Cyan'

<# 
Declare output path variable with Path and Filename

    - Use Conditional_Access_Framework_Groups_w_ID_Source.csv for Source Tenant
    - Use Conditional_Access_Framework_Groups_w_ID_Target.csv for Target Tenant
    - When you use the CA Policy Examples from this repo:
      https://github.com/philippkohn/ConditionalAccessforZeroTrustResources/tree/main/ConditionalAccessSamplePolicies 
    - You can use the existing CSV in the repo

#>
$OutputPath = Join-Path -Path "C:\Scripts\" -ChildPath "Conditional_Access_Framework_Groups_w_ID_Target.csv"

# Get all Microsoft Entra groups with display name starting with 'CA-' 
# Select only the relevant properties
# Export the Output to a CSV File
Get-MgGroup -Filter "startswith(displayName,'CA-')" | Select-Object DisplayName, Description, Id | Export-Csv -Path $OutputPath

#Disconnect Microsoft Graph API
Write-Host "Disconnect from existing Microsoft Graph API Sessions" -ForegroundColor Cyan
Disconnect-MgGraph

Write-Host ""
Write-Host "Exported Groups with ID for Mapping Table to prepare exported CA Policy JSON Files with new Group ID" -ForegroundColor Magenta
Write-Host "Output Path: $OutputPath" -ForegroundColor Cyan

# Clean-Up: Remove all custom variables
Write-Host "Remove all custom variables for security reasons" -ForegroundColor Magenta
Remove-Item Env:AZURE_CLIENT_ID
Remove-Item Env:AZURE_TENANT_ID
Remove-Variable -Name Scopes
Remove-Variable -Name Certificate
Remove-Variable -Name AppRegistration
Remove-Variable -Name tenantName
Remove-Variable -Name OutputPath

Write-Host ""
Write-Host "Done."