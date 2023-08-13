# Check PowerShell Version
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Throw "This script requires PowerShell 7 or a newer version."
}

# Connect to Microsoft Graph API
Write-Host "Connecting to Microsoft Graph API..." -ForegroundColor Magenta
$RequiredScopes = @('Application.Read.All', 'User.Read.All', 'Group.Read.All', 'Policy.ReadWrite.ConditionalAccess')
Write-Warning "Enter the Tenant ID of the tenant you want to connect to or leave blank to cancel"
$TenantID = Read-Host
if ($TenantID) {
    Connect-MgGraph -Scopes $RequiredScopes -TenantId $TenantID -ErrorAction Stop
} else {
    Write-Warning "No Tenant ID entered, aborting the script"
    exit
}

# Query for the path of the folder that contains the JSON files
$path = Read-Host "Enter the path of the folder that contains the Conditional Access Template Files in the JSON format"

# Get all JSON files from the folder
Write-Host "Getting all JSON files from the folder..." -ForegroundColor Magenta
$files = Get-ChildItem -Path $path -Filter *.json

# Loop through each file and import the Conditional Access policy
foreach ($file in $files) {
    Write-Host "Processing file: $($file.Name)..." -ForegroundColor Yellow

    # Read the JSON content from the current file
    $policyJson = Get-Content -Path $file.FullName -Raw


    # Use Invoke-MgGraphRequest to create a new Conditional Access policy
    try {
        $response = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body $policyJson -ContentType "application/json"
        Write-Host "Policy imported successfully from $($file.Name). Response:" $response.Content -ForegroundColor Green
    } catch {
        # Read the StreamContent and convert it to a string
        $errorContent = $_.Exception.Response.Content.ReadAsStringAsync().Result

        # Check if the error details are in JSON format
        if ($errorContent -match "^\s*\{.*\}\s*$") {
            $errorDetails = $errorContent | ConvertFrom-Json
            Write-Error "Failed to import policy from $($file.Name). Error: $($errorDetails.error.message)"
        } else {
            # If not in JSON format, just output the error content as a string
            Write-Error "Failed to import policy from $($file.Name). Error: $errorContent"
        }
    }
}

<# Read the JSON content from the provided file
$policyJson = Get-Content -Path "C:\Scripts\M365x77476191.onmicrosoft.com-08-13-2023\CA001-Global-BaseProtection-AllApps-AnyPlatform-BlockNonPersonas.json" -Raw

# Use Invoke-MgGraphRequest to create a new Conditional Access policy
try {
    $response = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body $policyJson -ContentType "application/json"
    Write-Host "Policy imported successfully. Response:" $response.Content
} catch {
    Write-Error "Failed to import policy. Error:" $_.Exception.Message
}
#>