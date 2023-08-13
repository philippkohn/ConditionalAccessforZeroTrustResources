<# 
.SYNOPSIS
    This script connects to Microsoft Graph API and exports a list of groups with a specific prefix to a CSV file.

.DESCRIPTION
    - This script checks the PowerShell version and requires PowerShell 7 or newer.
    - It disconnects from any existing Microsoft Graph API sessions and connects to a new one 
    - It then uses Get-MgGroup to filter the groups that start with ‘CA-’ and selects their DisplayName, Description, and Id properties. 
    - Finally, it exports the results to a CSV file in a specified path.

.PARAMETER
    OutputPath The path where the CSV file will be saved.

.OUTPUTS
    A CSV file with the group information.

#>

# Check PowerShell Version
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Throw "This script requires PowerShell 7 or a newer version."
}

# Try Discconnect Microsoft Graph API
Write-Host "Disconnect from existing Microsoft Graph API Sessions" -ForegroundColor Cyan
try{Disconnect-MgGraph -force -ErrorAction SilentlyContinue}catch{}

# Connect to Microsoft Graph API
Write-Host "Connecting to Microsoft Graph API..." -ForegroundColor Magenta
$RequiredScopes = @('User.Read.All', 'Organization.Read.All', 'Policy.Read.All')
Write-Warning "Enter the Tenant ID of the tenant you want to connect to or leave blank to cancel"
$TenantID = Read-Host
if ($TenantID) {
    Connect-MgGraph -Scopes $RequiredScopes -TenantId $TenantID -ErrorAction Stop
} else {
    Write-Warning "No Tenant ID entered, aborting the script"
    exit
}

<# 
Declare output path variable with Path and Filename

    - Use Conditional_Access_Framework_Groups_w_ID_Source.csv for Source Tenant
    - Use Conditional_Access_Framework_Groups_w_ID_Target.csv for Target Tenant
    - When you use the CA Policy Examples from this repo:
      https://github.com/philippkohn/ConditionalAccessforZeroTrustResources/tree/main/ConditionalAccessSamplePolicies 
    - You can use the existing CSV in the repo

#>
$OutputPath = Join-Path -Path "C:\Scripts\" -ChildPath "Conditional_Access_Framework_Groups_w_ID_Source.csv"

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

Write-Host ""
Write-Host "Done."