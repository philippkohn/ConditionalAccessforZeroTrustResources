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
$RequiredScopes = @('Group.Write.All')
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

# Create security groups
Write-Host "Creating security groups..."
New-MgGroup -DisplayName 'CA-BreakGlassAccounts' -MailEnabled:$false -MailNickname 'CA-BreakGlassAccounts' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-Admins' -MailEnabled:$false -MailNickname 'CA-Persona-Admins' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-Admins-Exclusions' -MailEnabled:$false -MailNickname 'CA-Persona-Admins-Exclusions' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-AzureServiceAccounts' -MailEnabled:$false -MailNickname 'CA-Persona-AzureServiceAccounts' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-AzureServiceAccounts-Exclusions' -MailEnabled:$false -MailNickname 'CA-Persona-AzureServiceAccounts-Exclusions' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-Externals' -MailEnabled:$false -MailNickname 'CA-Persona-Externals' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-Externals-Exclusions' -MailEnabled:$false -MailNickname 'CA-Persona-Externals-Exclusions' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-Global-Exclusions' -MailEnabled:$false -MailNickname 'CA-Persona-Global-Exclusions' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-GuestAdmins' -MailEnabled:$false -MailNickname 'CA-Persona-GuestAdmins' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-GuestAdmins-Exclusions' -MailEnabled:$false -MailNickname 'CA-Persona-GuestAdmins-Exclusions' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-Guests-Exclusions' -MailEnabled:$false -MailNickname 'CA-Persona-Guests-Exclusions' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-Internals' -MailEnabled:$false -MailNickname 'CA-Persona-Internals' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-Internals-Exclusions' -MailEnabled:$false -MailNickname 'CA-Persona-Internals-Exclusions' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-Microsoft365ServiceAccounts' -MailEnabled:$false -MailNickname 'CA-Persona-Microsoft365ServiceAccounts' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-Microsoft365ServiceAccounts-Exclusions' -MailEnabled:$false -MailNickname 'CA-Persona-Microsoft365ServiceAccounts-Exclusions' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-OnPremisesServiceAccounts' -MailEnabled:$false -MailNickname 'CA-Persona-OnPremisesServiceAccounts' -SecurityEnabled:$true
New-MgGroup -DisplayName 'CA-Persona-OnPremisesServiceAccounts-Exclusions' -MailEnabled:$false -MailNickname 'CA-Persona-OnPremisesServiceAccounts-Exclusions' -SecurityEnabled:$true

#Disconnect Microsoft Graph API
Write-Host "Disconnect from existing Microsoft Graph API Sessions"
Disconnect-MgGraph

Write-Host ""
Write-Host "Created all needed Security Groups for the Conditional Access Framework from Microsoft employee - Claus Jespersen; Change 10.08.23 only one exclusion Group per Persona" 

Write-Host ""
Write-Host "Done."