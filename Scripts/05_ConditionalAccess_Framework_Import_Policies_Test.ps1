# Check PowerShell Version
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Throw "This script requires PowerShell 7 or a newer version."
}

# Connect to Microsoft Graph API
Write-Host "Connecting to Microsoft Graph API..." -ForegroundColor Magenta
$RequiredScopes = @('User.Read.All', 'Group.Read.All', 'Policy.ReadWrite.ConditionalAccess')
Write-Warning "Enter the Tenant ID of the tenant you want to connect to or leave blank to cancel"
$TenantID = Read-Host
if ($TenantID) {
    Connect-MgGraph -Scopes $RequiredScopes -TenantId $TenantID -ErrorAction Stop
} else {
    Write-Warning "No Tenant ID entered, aborting the script"
    exit
}


# Read the JSON content from the provided file
$policyJson = Get-Content -Path "C:\Scripts\M365x77476191.onmicrosoft.com-08-13-2023\CA001-Global-BaseProtection-AllApps-AnyPlatform-BlockNonPersonas.json" -Raw

# Use Invoke-MgGraphRequest to create a new Conditional Access policy
try {
    $response = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body $policyJson -ContentType "application/json"
    Write-Host "Policy imported successfully. Response:" $response.Content
} catch {
    Write-Error "Failed to import policy. Error:" $_.Exception.Message
}
