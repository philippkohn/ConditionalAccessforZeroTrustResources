<#
.SYNOPSIS
This script exports Conditional Access policies from Microsoft Graph and saves them as individual JSON files.

.DESCRIPTION
- The script first ensures that it's running on PowerShell Version 7.x or newer.
- It attempts to disconnect any existing sessions with Microsoft Graph API.
- Environment variables are set for authentication.
- The user connects to the Microsoft Graph PowerShell SDK using client credentials and a certificate thumbprint.
- Retrieves the built-in onmicrosoft.com domain name of the tenant and displays the connection details.
- Fetches all Conditional Access policies and exports them as separate JSON files. 
  Note: The exported policies are set to a 'disabled' state to prevent potential lockouts.
- A summary of the exported policies is displayed in the PowerShell shell.
- Includes cleanup operations to remove sensitive data from the session.

.OUTPUTS
A directory containing individual JSON files for each Conditional Access policy, accompanied by a summary table displayed within the shell.

.NOTES
File Name      : 01_ConditionalAccess_Framework_Export_Policies.ps1
Author         : Philipp Kohn, Assisted by OpenAI's ChatGPT
Prerequisite   : PowerShell 7.x or newer. Microsoft Graph PowerShell SDK.
Copyright 2023 : cloudcopilot.de

Change Log
----------
Date       Version   Author          Description
--------   -------   ------          -----------
15/07/23   1.0       Philipp Kohn    Initial version.
12/08/23   1.1       Philipp Kohn    Added a query of TenantID to mitigate risks.
13/08/23   1.2       Philipp Kohn    Improved colors and formatting.
14/08/23   1.3       Philipp Kohn    Transitioned to Certificate-Based Authentication
18/08/23   1.4       Philipp Kohn    Tested in Lab, updated some comments
#>

# Check PowerShell Version
Write-Host "Check if running PowerShell Version 7.x" -ForegroundColor 'Cyan'
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Throw "This script requires PowerShell 7 or a newer version."
}

# Try Discconnect Microsoft Graph API
Write-Host "Disconnect from existing Microsoft Graph API Sessions"
try{Disconnect-MgGraph -ErrorAction SilentlyContinue}catch{}


# Add environment variables to be used by Connect-MgGraph
$env:AZURE_CLIENT_ID = "YOUR Client ID from your App Registration in Microsoft Entra"
$env:AZURE_TENANT_ID = "YOUR Tenant ID"

# Add environment variable with the Thumbprint of your Certificate
$Certificate = "The Tumbprint of your Certificate"

# Connect to Microsoft Graph PowerShell SDK
Connect-MgGraph -ClientId $env:AZURE_CLIENT_ID -TenantId $env:AZURE_TENANT_ID -CertificateThumbprint $Certificate

# Connection Infos for Microsoft Graph PowerShell SDK Connection
Write-Host "Getting the built-in onmicrosoft.com domain name of the tenant..."
$tenantName = (Get-MgOrganization).VerifiedDomains | Where-Object {$_.IsInitial -eq $true} | Select-Object -ExpandProperty Name
$AppRegistration = (Get-MgContext | Select-Object -ExpandProperty AppName)
$Scopes = (Get-MgContext | Select-Object -ExpandProperty Scopes)
Write-Host "Tenant: $tenantName" -ForegroundColor 'Cyan'
Write-Host "AppRegistration: $AppRegistration" -ForegroundColor 'Magenta'
Write-Host "Scopes: $Scopes" -ForegroundColor 'Cyan'

# Get all Conditional Access policies
Write-Host "Getting all Conditional Access policies..."
$policies = Invoke-MgGraphRequest -Method GET https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies | Select-Object -ExpandProperty Value

# Get the current date in MM-dd-yyyy format
Write-Host "Getting the current date in MM-dd-yyyy format..." -ForegroundColor 'Cyan'
$date = Get-Date -Format "MM-dd-yyyy"

# Create a folder named after the built-in onmicrosoft.com domain name of the tenant and the date of the export
Write-Host "Creating a folder named after the built-in onmicrosoft.com domain name of the tenant and the date of the export..." -ForegroundColor 'Magenta'
$path = "c:\scripts\$tenantName-$date"
New-Item -ItemType Directory -Path $path | Out-Null

# Export all Conditional Access policies to separate JSON files with their actual name and display a summary of the exported policies in the shell
Write-Host "Exporting all Conditional Access policies to separate JSON files with their actual name and displaying a summary of the exported policies in the shell..." -ForegroundColor 'Cyan' 
$summary = @()
foreach ($policy in $policies) {
    # Remove id, createdDateTime and modifiedDateTime from policy object
    $policy = $policy | Select-Object -Property * -ExcludeProperty id, createdDateTime, modifiedDateTime
    # Change state from enabled to disabled
    # Don't lock yourself out please use ReportOnly and configure and test the Breakglass Accounts before enabling the policies
    $policy.state = "disabled"
    $name = $policy.DisplayName.Replace('/', '_')
    $file = "$path\$name.json"
    $policy | ConvertTo-Json -Depth 10 | Out-File -FilePath $file
    $summary += [PSCustomObject]@{
        Name = $policy.DisplayName
        Id = $policy.Id
        File = $file
    }
}

#Disconnect Microsoft Graph API
Write-Host "Disconnect from existing Microsoft Graph API Sessions" -ForegroundColor 'Magenta' 
Disconnect-MgGraph

Write-Host ""
$summary | Sort-Object Name | Select-Object Name | Format-Table -AutoSize
Write-Host ""
Write-Host "Exported all Conditional Access policies for $($tenantName) to $($path)" -ForegroundColor 'Cyan'

# Clean-Up: Remove all custom variables
Write-Host "Remove all custom variables for security reasons" -ForegroundColor Magenta
Remove-Item Env:AZURE_CLIENT_ID
Remove-Item Env:AZURE_TENANT_ID
Remove-Variable -Name Certificate
Remove-Variable -Name tenantName
Remove-Variable -Name AppRegistration
Remove-Variable -Name Scopes
Remove-Variable -Name policies
Remove-Variable -Name policy
Remove-Variable -Name summary

Write-Host "Done."