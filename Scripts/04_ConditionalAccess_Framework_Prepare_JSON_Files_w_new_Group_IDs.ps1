<#
.SYNOPSIS
Updates the group IDs in JSON files for conditional access policies to prepare them for Import in another Tenant

.DESCRIPTION
- This script initiates by checking if the PowerShell version is 7 or newer.
- It then prompts the user for the file path for the source and target group mappings CSV files and the folder path for the JSON files.
- The script imports source and target groups from the CSV files and creates a hashtable to map old IDs to new IDs.
- It then fetches all JSON files from the specified path and loops through each file, replacing the group IDs in the conditions.users.excludeGroups and conditions.users.includeGroups properties using the hashtable.
- Finally, the updated content overwrites the original JSON files

.OUTPUTS
The script modifies the JSON files in place with updated group IDs.

.NOTES
File Name      : 04_ConditionalAccess_Framework_Prepare_JSON_Files_w_new_Group_IDs.ps1
Author         : Philipp Kohn, Assisted by OpenAI's ChatGPT
Prerequisite   : PowerShell 7.x or newer.
Copyright 2023 : cloudcopilot.de

Change Log
----------
Date       Version   Author         Description
--------   -------   ------         -----------
14/08/23   1.0       Philipp Kohn   Rebuild from scratch, optimized for simplicity, added status updates, and formatted documentation.
18/08/23   1.1       Philipp Kohn   Tested in Lab, updated some comments

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

# Check PowerShell Version
if ($PSVersionTable.PSVersion.Major -lt 7) {
  Throw "This script requires PowerShell 7 or a newer version."
}

# User provided parameters or prompts for the file paths
$FilePath = Read-Host -Prompt "Enter the file path for the source and target group mappings CSV files"
$JsonFilesPath = Read-Host -Prompt "Enter the folder path for the JSON files"

Write-Host "Importing source and target groups from CSV files..." -ForegroundColor Cyan

# Import source and target groups from CSV files
$SourceGroups = Import-Csv -Path "$FilePath\Conditional_Access_Framework_Groups_w_ID_Source.csv"
$TargetGroups = Import-Csv -Path "$FilePath\Conditional_Access_Framework_Groups_w_ID_Target.csv"

Write-Host "Creating a hashtable to map old IDs to new IDs..." -ForegroundColor Magenta

# Create a hashtable to map old IDs to new IDs
$GroupMap = @{}
foreach ($i in 0..($SourceGroups.Count-1)) {
  $GroupMap[$SourceGroups[$i].Id] = $TargetGroups[$i].Id
}

Write-Host "Fetching all JSON files from the specified path..." -ForegroundColor Cyan

# Fetch all JSON files from the specified path
$JsonFiles = Get-ChildItem -Path "$JsonFilesPath" -Filter "*.json"
$fileCount = $JsonFiles.Count
$currentCount = 0

# Loop through each JSON file for processing
foreach ($JsonFile in $JsonFiles) {
  $currentCount++
  # Provide progress update to the user
  Write-Progress -PercentComplete (($currentCount / $fileCount) * 100) -Status "Processing file $currentCount of $fileCount" -Activity "Updating JSON files"

  Write-Host "Processing file $currentCount of $fileCount $JsonFile" -ForegroundColor Magenta

  # Read and convert JSON content to a PowerShell object
  $JsonContent = Get-Content -Path $JsonFile.FullName -Raw | ConvertFrom-Json

  # Loop through both excludeGroups and includeGroups properties for ID replacements
  foreach ($property in @('excludeGroups', 'includeGroups')) {
      for ($i = 0; $i -lt $JsonContent.conditions.users.$property.Count; $i++) {
          $Group = $JsonContent.conditions.users.$property[$i]
          # Check and replace IDs using the provided hashtable
          if ($GroupMap.ContainsKey($Group)) {
              $JsonContent.conditions.users.$property[$i] = $GroupMap[$Group]
          }
      }
  }

  # Convert the updated PowerShell object back to JSON and save it
  $JsonContent | ConvertTo-Json -Depth 4 | Set-Content -Path $JsonFile.FullName

  Write-Host "Finished processing file $currentCount of $fileCount $JsonFile" -ForegroundColor Cyan
}

# Display completion messages to the user
Write-Host ""
Write-Host "Prepared the exported Conditional Access JSON Files with new Group IDs from the Groups of the Target Tenant" -ForegroundColor Magenta
Write-Host ""
Write-Host "Done." -ForegroundColor Cyan