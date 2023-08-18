<#
.SYNOPSIS
This script imports Conditional Access policies from JSON templates into Microsoft Entra.

.DESCRIPTION
- The script first ensures that it's running on PowerShell Version 7.x or newer.
- It attempts to disconnect any existing sessions with Microsoft Graph API.
- Environment variables are set for authentication and the user connects to Microsoft Graph PowerShell SDK.
- Then it connects the Microsoft Graph PowerShell SDK using client credentials and a certificate thumbprint.
- The script then retrieves and displays information about the tenant, App registration, and scopes.
- It checks for the existence of the 'Microsoft Intune Enrollment' Service Principal and creates it if not found.
- The user is prompted to provide the path of the folder containing Conditional Access policies in JSON format.
- The script reads each JSON file and imports the corresponding Conditional Access policy.

.OUTPUTS
The script provides outputs on the console regarding:
- The PowerShell version being used.
- Connection status with Microsoft Graph API.
- Details about the tenant, App registration, and scopes.
- The existence of the 'Microsoft Intune Enrollment' Service Principal.
- Status of the import process for each JSON file.

.NOTES
File Name      : 05_ConditionalAccess_Framework_Import_Policies.ps1
Author         : Philipp Kohn, Assisted by OpenAI's ChatGPT
Prerequisite   : PowerShell 7.x or newer. Microsoft Graph PowerShell SDK.
Copyright 2023 : cloudcopilot.de

Change Log
----------
Date       Version   Author          Description
--------   -------   ------          -----------
18/08/23   1.0       Philipp Kohn    Initial version
18/08/23   1.1       Philipp Kohn    Tested in Lab, updated some comments

*** When you are using this script to Deploy the Sample Policies from https://github.com/philippkohn/ConditionalAccessforZeroTrustResources/tree/main/ConditionalAccessSamplePolicies
    you have to recreate the Microsoft Entra Terms of Use Policies (ToU) manually. Grab the ID with "Get-MgAgreement | fl Displayname, Id" in Lab Tenant there were two ToU Polices
   
    DisplayName : Contoso - Terms of Use - GuestAdmins
    Id          : 6551cec0-1d10-422b-a9d0-9e447e0a8353

    DisplayName : Contoso - Terms of Use - Guests
    Id          : 0272f2a4-dba2-4135-8197-563b3a420d34 
   
    Please use this PowerPoint Slides for further Information: 
    https://view.officeapps.live.com/op/view.aspx?src=https%3A%2F%2Fraw.githubusercontent.com%2Fphilippkohn%2FConditionalAccessforZeroTrustResources%2Fmain%2FConditional%2520Access%2520for%2520Zero%2520Trust%2520-%2520Philipp%2520Kohn%2520-%252011-08-13.ppsx&wdOrigin=BROWSELINK

***
#>

# Check for the required PowerShell version
Write-Host "Check if running PowerShell Version 7.x" -ForegroundColor 'Cyan'
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Throw "This script requires PowerShell 7 or a newer version."
}

# Disconnect from any existing sessions with the Microsoft Graph API
Write-Host "Disconnect from existing Microsoft Graph API Sessions" -ForegroundColor Cyan
try{Disconnect-MgGraph -ErrorAction SilentlyContinue}catch{}

# Set environment variables for client and tenant ID
$env:AZURE_CLIENT_ID = "YOUR Client ID from your App Registration in Microsoft Entra"
$env:AZURE_TENANT_ID = "YOUR Tenant ID"

# Provide the certificate thumbprint for authentication
$Certificate = "The Tumbprint of your Certificate"

# Connect to the Microsoft Graph using the provided environment variables
Connect-MgGraph -ClientId $env:AZURE_CLIENT_ID -TenantId $env:AZURE_TENANT_ID -CertificateThumbprint $Certificate

# Retrieve and display details about the current connection
Write-Host "Getting the built-in onmicrosoft.com domain name of the tenant..." -ForegroundColor Magenta
$tenantName = (Get-MgOrganization).VerifiedDomains | Where-Object {$_.IsInitial -eq $true} | Select-Object -ExpandProperty Name
$AppRegistration = (Get-MgContext | Select-Object -ExpandProperty AppName)
$Scopes = (Get-MgContext | Select-Object -ExpandProperty Scopes)
Write-Host "Tenant: $tenantName" -ForegroundColor 'Cyan'
Write-Host "AppRegistration: $AppRegistration" -ForegroundColor 'Magenta'
Write-Host "Scopes: $Scopes" -ForegroundColor 'Cyan'

# Check for the existence of a particular Service Principal
$servicePrincipal = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Intune Enrollment'"

# Create the Service Principal if not found
if ($servicePrincipal) {
    Write-Host "Service Principal 'Microsoft Intune Enrollment' exists in the tenant." -ForegroundColor Green
} else {
    Write-Host "Service Principal 'Microsoft Intune Enrollment' does not exist in the tenant. Creating now..." -ForegroundColor Yellow

    # Create the Service Principal with the specified AppId
    try {
        New-MgServicePrincipal -AppId "d4ebce55-015a-49b5-a083-c84d1797ae8c"
        Write-Host "Service Principal 'Microsoft Intune Enrollment' created successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to create Service Principal 'Microsoft Intune Enrollment'. Error: $_" -ForegroundColor Red
    }
}

# Prompt the user for the folder path containing JSON templates of Conditional Access policies
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