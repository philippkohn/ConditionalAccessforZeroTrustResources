<#
.SYNOPSIS 
    This PowerShell script connects to Microsoft Graph API, creates security groups for conditional access policies, and gets the tenant name and user context.

.DESCRIPTION
    This PowerShell script performs the following tasks:
    - Disconnects from any existing Microsoft Graph API sessions
    - Connects to Microsoft Graph API with the specified scopes and asks for the TenantID to which Tenant the script should connect
    - Gets the built-in onmicrosoft.com domain name of the tenant
    - Gets the current user context and prompts the user to confirm the correct tenant
    - Creates all needed Security Groups for the Conditional Access Framework from Microsoft employee - Claus Jespersen

.NOTES
    Author        Philipp Kohn, cloudcopilot.de, Twitter: @philipp_kohn
    Change Log    V1.00, 15/07/2023 - Initial version
    Change Log    V1.01, 10/08/2023 - Only one exclusion Group per Persona
    Change Log    V1.02, 12/08/2023 - Added query of TenantID to mitigate the risk of using the script in the wrong Tenant
    Change Log    V1.03, 13/08/2023 - Modified the script to use a Variable and loop through the group creation

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
$RequiredScopes = @('Group.ReadWrite.All', 'Directory.ReadWrite.All')
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

# Define an array of groups
$groups = @(
    'CA-BreakGlassAccounts'
    'CA-Persona-Admins'
    'CA-Persona-Admins-Exclusions'
    'CA-Persona-AzureServiceAccounts'
    'CA-Persona-AzureServiceAccounts-Exclusions'
    'CA-Persona-Externals'
    'CA-Persona-Externals-Exclusions'
    'CA-Persona-Global-Exclusions'
    'CA-Persona-GuestAdmins'
    'CA-Persona-GuestAdmins-Exclusions'
    'CA-Persona-Guests-Exclusions'
    'CA-Persona-Internals'
    'CA-Persona-Internals-Exclusions'
    'CA-Persona-Microsoft365ServiceAccounts'
    'CA-Persona-Microsoft365ServiceAccounts-Exclusions'
    'CA-Persona-OnPremisesServiceAccounts'
    'CA-Persona-OnPremisesServiceAccounts-Exclusions'
)

# Loop through the array and create security groups
Write-Host "Creating security groups..."
foreach ($group in $groups) {
    New-MgGroup -DisplayName $group -MailEnabled:$false -MailNickname $group -SecurityEnabled:$true
}

#Disconnect Microsoft Graph API
Write-Host "Disconnect from existing Microsoft Graph API Sessions"
Disconnect-MgGraph

Write-Host ""
Write-Host "Created all needed Security Groups for the Conditional Access Framework from Microsoft employee - Claus Jespersen; Change 10.08.23 only one exclusion Group per Persona" 

Write-Host ""
Write-Host "Done."