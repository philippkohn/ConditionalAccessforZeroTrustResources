<# 
.SYNOPSIS
    This script connects to Microsoft Graph API and exports a list of groups with a specific prefix to a CSV file.

.DESCRIPTION
    - This script checks the PowerShell version and requires PowerShell 7 or newer.
    - It disconnects from any existing Microsoft Graph API sessions and connects to a new one with the Group.Read.All scope. 
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
Write-Host "Disconnect from existing Microsoft Graph API Sessions"
try{Disconnect-MgGraph -ErrorAction SilentlyContinue}catch{}

# Connect to Microsoft Graph API
Write-Host "Connecting to Microsoft Graph API..."
Connect-MgGraph -Scopes 'Group.Read.All'

# Declare output path variable
$OutputPath = Join-Path -Path "C:\Scripts\" -ChildPath "Conditional_Access_Framework_Groups_w_ID_Target.csv"

Get-MgGroup -Filter "startswith(displayName,'CA-')" | Select-Object DisplayName, Description, Id | Export-Csv -Path $OutputPath