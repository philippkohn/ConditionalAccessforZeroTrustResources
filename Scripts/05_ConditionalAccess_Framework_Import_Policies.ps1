<#
.SYNOPSIS
Imports all Conditional Access policies from separate JSON files with their actual name.

.DESCRIPTION
This script imports all Conditional Access policies from separate JSON files with their actual name and creates them as read-only policies in Microsoft Entra.

.PARAMETER Path
The path to the folder containing the JSON files.

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
Write-Warning "Enter the Tenant ID of the tenant you want to connect to or leave blank to cancel"
$TenantID = Read-Host
if ($TenantID) {
    Connect-MgGraph -Scopes $RequiredScopes -TenantId $TenantID -ErrorAction Stop
} else {
    Write-Warning "No Tenant ID entered, aborting the script"
    exit
}

# Connect to Microsoft Graph API
Write-Host "Connecting to Microsoft Graph API..."
Connect-MgGraph -Scopes 'User.Read.All', 'Organization.Read.All', 'Policy.ReadWrite.ConditionalAccess', 'Group.ReadWrite.All' -ErrorAction Stop

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
} else {
    # handle invalid input
}

# Show a folder selection dialog box to select the folder containing the JSON files
$dialog = New-Object System.Windows.Forms.FolderBrowserDialog
$dialog.Description = "Select the folder containing the JSON files."
$dialog.ShowNewFolderButton = $false
$result = $dialog.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $path = $dialog.SelectedPath

    # Get all JSON files in the specified folder
    Write-Host "Getting all JSON files in the specified folder..."
    $files = Get-ChildItem -Path $path -Filter *.json

    # Import all Conditional Access policies from the JSON files and create them as read-only policies in Azure AD
    Write-Host "Importing all Conditional Access policies from the JSON files and creating them as read-only policies in Azure AD..."
    foreach ($file in $files) {
        $policy = Import-CliJSON -Path $file.FullName
        New-MgIdentityConditionalAccessPolicy -InputObject $policy -ReadOnly:$true
    }

    Write-Host ""
    Write-Host "Imported all Conditional Access policies from $($files.Count) JSON files in $($path)"

    Write-Host ""
    Write-Host "Done."
}