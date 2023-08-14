<#
.SYNOPSIS
Connects to Microsoft Graph API, creates security groups for conditional access policies, and fetches the tenant name and user context.

.DESCRIPTION
This script initiates by verifying the PowerShell version and disconnecting from any existing Microsoft Graph API sessions. It then establishes a connection to the Microsoft Graph API using the specified environment variables and certificate thumbprint. Post connection, it fetches the built-in onmicrosoft.com domain name of the tenant and retrieves the current user context. Users are prompted to confirm the tenant details. Once confirmed, the script proceeds to create the necessary security groups for the Conditional Access Framework. On completion, the script disconnects from the Microsoft Graph API and provides a summary of the created groups.

.OUTPUTS
A confirmation of the created security groups in the Microsoft Graph, accompanied by a summary of the operations executed.

.NOTES
File Name      : 02_ConditionalAccess_Framework_Create_Groups.ps1
Author         : Philipp Kohn, Assisted by OpenAI's ChatGPT
Prerequisite   : PowerShell 7.x or newer. Microsoft Graph PowerShell SDK.
Copyright 2023 : cloudcopilot.de

Change Log
----------
Date       Version   Author         Description
--------   -------   ------         -----------
15/07/23   1.0       Philipp Kohn   Initial version.
10/08/23   1.1       Philipp Kohn   Updated to create only one exclusion group per persona.
12/08/23   1.2       Philipp Kohn   Added query of TenantID to mitigate risks.
13/08/23   1.3       Philipp Kohn   Modified to use a loop for group creation.
14/08/23   1.4       Philipp Kohn   Changed Authentication to Certificate-based Auth, Optimized user prompts and environment variable clean-up.
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
Write-Warning "Press any key to continue or Ctrl+C to cancel"
$null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Define an array of groups
$groups = @(
    'TEST1-CA-BreakGlassAccounts'
    'TEST1-CA-Persona-Admins'
    'TEST1-CA-Persona-Admins-Exclusions'
    'TEST1-CA-Persona-AzureServiceAccounts'
    'TEST1-CA-Persona-AzureServiceAccounts-Exclusions'
    'TEST1-CA-Persona-Externals'
    'TEST1-CA-Persona-Externals-Exclusions'
    'TEST1-CA-Persona-Global-Exclusions'
    'TEST1-CA-Persona-GuestAdmins'
    'TEST1-CA-Persona-GuestAdmins-Exclusions'
    'TEST1-CA-Persona-Guests-Exclusions'
    'TEST1-CA-Persona-Internals'
    'TEST1-CA-Persona-Internals-Exclusions'
    'TEST1-CA-Persona-Microsoft365ServiceAccounts'
    'TEST1-CA-Persona-Microsoft365ServiceAccounts-Exclusions'
    'TEST1-CA-Persona-OnPremisesServiceAccounts'
    'TEST1-CA-Persona-OnPremisesServiceAccounts-Exclusions'
)

# Loop through the array and create security groups
Write-Host "Creating security groups..." -ForegroundColor Magenta
foreach ($group in $groups) {
    New-MgGroup -DisplayName $group -MailEnabled:$false -MailNickname $group -SecurityEnabled:$true
}

# Disconnect Microsoft Graph API
Write-Host "Disconnect from existing Microsoft Graph API Sessions" -ForegroundColor Cyan
Disconnect-MgGraph

# Clean-Up: Remove all custom variables
Write-Host "Remove all custom variables for security reasons" -ForegroundColor Cyan
Remove-Item Env:AZURE_CLIENT_ID
Remove-Item Env:AZURE_TENANT_ID
Remove-Variable -Name Scopes
Remove-Variable -Name Certificate
Remove-Variable -Name group
Remove-Variable -Name groups
Remove-Variable -Name AppRegistration
Remove-Variable -Name tenantName

Write-Host ""
Write-Host "Created all needed Security Groups for the Conditional Access Framework from Microsoft employee - Claus Jespersen; Change 10.08.23 only one exclusion Group per Persona" -ForegroundColor Magenta

Write-Host ""
Write-Host "Done."