<#
.SYNOPSIS 
    Imports Conditional Access policies from JSON files to another tenant.

.DESCRIPTION
    This script queries for the path of the folder that contains the JSON files with the Conditional Access policies. 
    It then reads each policy object from the JSON file and invokes a POST request to create the policy in the target tenant using the Microsoft Graph API.
    It also displays a summary of the imported policies in the shell.

.OUTPUTS
    A summary of the imported policies, including their name, id and file path.

.NOTES
    Author        Philipp Kohn, cloudcopilot.de, Twitter: @philipp_kohn
    Change Log    V1.00, 13/08/2023 - Initial version
    Change Log    V1.01, 13/08/2023 - Minor changes
    
#>

# Check PowerShell Version
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Throw "This script requires PowerShell 7 or a newer version."
}

# Try Discconnect Microsoft Graph API
Write-Host "Disconnect from existing Microsoft Graph API Sessions"
try{Disconnect-MgGraph -force -ErrorAction SilentlyContinue}catch{}

# Connect to Microsoft Graph API
Write-Host "Connecting to Microsoft Graph API..."
$RequiredScopes = @('User.Read.All', 'Group.Read.All', 'Policy.ReadWrite.All')
Write-Warning "Enter the Tenant ID of the tenant you want to connect to or leave blank to cancel"
$TenantID = Read-Host
if ($TenantID) {
    Connect-MgGraph -Scopes $RequiredScopes -TenantId $TenantID -ErrorAction Stop
} else {
    Write-Warning "No Tenant ID entered, aborting the script"
    exit
}

# Get the built-in onmicrosoft.com domain name of the tenant
Write-Host "Getting the built-in onmicrosoft.com domain name of the tenant..."
$tenantName = (Get-MgOrganization).VerifiedDomains | Where-Object {$_.IsInitial -eq $true} | Select-Object -ExpandProperty Name
$CurrentUser = (Get-MgContext | Select-Object -ExpandProperty Account)
Write-Host "Tenant: $tenantName" -ForegroundColor 'Magenta'
Write-Host "User: $CurrentUser" -ForegroundColor 'Cyan'
Write-Warning "Press any key to continue or Ctrl+C to cancel"
$null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Query for the path of the folder that contains the JSON files
$path = Read-Host "Enter the path of the folder that contains the Conditional Access Template Files in the JSON format"

# Get all JSON files from the folder
Write-Host "Getting all JSON files from the folder..."
$files = Get-ChildItem -Path $path -Filter *.json

# Import all Conditional Access policies from JSON files and display a summary of the imported policies in the shell
Write-Host "Importing all Conditional Access policies from JSON files and displaying a summary of the imported policies in the shell..."
$summary = @()
foreach ($file in $files) {
    # Read the policy object from the JSON file
    $policy = Get-Content -Path $file.FullName | ConvertFrom-Json
    # Invoke a POST request to create the policy in the target tenant
    $result = Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies -Body $policy
    $summary += [PSCustomObject]@{
        Name = $policy.DisplayName
        Id = $result.Id
        File = $file.FullName
    }
}

#Disconnect Microsoft Graph API
Write-Host "Disconnect from existing Microsoft Graph API Sessions" -ForegroundColor Cyan
Disconnect-MgGraph

Write-Host ""
$summary | Format-Table -AutoSize
Write-Host "Imported all Conditional Access policies to $($tenantName) from $($path)" -ForegroundColor Magenta
Write-Host "Done."