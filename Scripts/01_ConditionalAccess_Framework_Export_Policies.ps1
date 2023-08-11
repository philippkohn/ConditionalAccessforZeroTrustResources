<#
.SYNOPSIS 
    Exports all Conditional Access policies from a tenant to separate JSON files.

.DESCRIPTION
    This script connects to the Microsoft Graph API and retrieves all Conditional Access policies from a tenant. It then creates a folder named after the built-in onmicrosoft.com domain name of the tenant and the date of the export, and exports each policy to a separate JSON file with its actual name. It also displays a summary of the exported policies in the shell.

.OUTPUTS
    A folder containing JSON files for each Conditional Access policy, and a summary table in the shell.

.NOTES
    Author        Philipp Kohn, cloudcopilot.de, Twitter: @philipp_kohn
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
$RequiredScopes = @('User.Read.All', 'Organization.Read.All', 'Policy.Read.All')
Connect-MgGraph -Scopes $RequiredScopes -ErrorAction Stop

# Get the built-in onmicrosoft.com domain name of the tenant
Write-Host "Getting the built-in onmicrosoft.com domain name of the tenant..."
$tenantName = (Get-MgOrganization).VerifiedDomains | Where-Object {$_.IsInitial -eq $true} | Select-Object -ExpandProperty Name
$CurrentUser = (Get-MgContext | Select-Object -ExpandProperty Account)
#Write-Host "Tenant: $tenantName" -ForegroundColor 'Red' -BackgroundColor 'DarkGray'
#Write-Host "User: $CurrentUser" -ForegroundColor 'Green' -BackgroundColor 'DarkGray'
Write-Warning "Tenant: $tenantName"
Write-Warning "User: $CurrentUser"
Write-Host "!!IMPORTANT!! Please Check if you are logged in to the correct tenant - Take your time - Don't shoot yourself in the foot" -ForegroundColor 'Red' -BackgroundColor 'Black'
$answer = Read-Host -Prompt "Enter y for yes or n for no"
if ($answer -eq "y") {
    # continue the script
} elseif ($answer -eq "n") {
    # stop the script
    Disconnect-MgGraph
} else {
    # handle invalid input
}

# Get all Conditional Access policies
Write-Host "Getting all Conditional Access policies..."
$policies = Invoke-MgGraphRequest -Method GET https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies | Select-Object -ExpandProperty Value

# Get the current date in MM-dd-yyyy format
Write-Host "Getting the current date in MM-dd-yyyy format..."
$date = Get-Date -Format "MM-dd-yyyy"

# Create a folder named after the built-in onmicrosoft.com domain name of the tenant and the date of the export
Write-Host "Creating a folder named after the built-in onmicrosoft.com domain name of the tenant and the date of the export..."
$path = "c:\scripts\$tenantName-$date"
New-Item -ItemType Directory -Path $path | Out-Null

# Export all Conditional Access policies to separate JSON files with their actual name and display a summary of the exported policies in the shell
Write-Host "Exporting all Conditional Access policies to separate JSON files with their actual name and displaying a summary of the exported policies in the shell..."
$summary = @()
foreach ($policy in $policies) {
    # Remove id, createdDateTime and modifiedDateTime from policy object
    $policy = $policy | Select-Object -Property * -ExcludeProperty id, createdDateTime, modifiedDateTime
    $name = $policy.DisplayName.Replace('/', '_')
    $file = "$path\$name.json"
    $policy | ConvertTo-Json -Depth 10 | Out-File -FilePath $file
    $summary += [PSCustomObject]@{
        Name = $policy.DisplayName
        Id = $policy.Id
        File = $file
    }
}
$summary | Format-Table -AutoSize
Disconnect-MgGraph
Write-Host ""
Write-Host "Exported all Conditional Access policies for $($tenantName) to $($path)"
Write-Host ""
Write-Host "Done."