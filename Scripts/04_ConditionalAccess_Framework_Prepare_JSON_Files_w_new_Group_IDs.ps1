<#
.SYNOPSIS
  This script updates the group IDs in the JSON files for conditional access policies to prepare them for Import


.DESCRIPTION
  This script reads the source and target group mappings from two CSV files and creates a hashtable to store the old and new ID values. Then it loops through each JSON file in a folder and replaces the group IDs in the conditions.users.excludeGroups and conditions.users.includeGroups properties with the corresponding values from the hashtable. Finally, it overwrites the JSON files with the updated content.

.OUTPUTS
  None. The script modifies the JSON files in place.

.NOTES
  Author        Philipp Kohn, cloudcopilot.de, Twitter: @philipp_kohn

#>

# Check PowerShell Version
if ($PSVersionTable.PSVersion.Major -lt 7) {
  Throw "This script requires PowerShell 7 or a newer version."
}

# Ask for the source and target group mappings file path
$FilePath = Read-Host -Prompt "Enter the file path for the source and target group mappings CSV files"

# Get the source and target group mappings from the CSV files
$SourceGroups = Import-Csv -Path "$FilePath\Conditional_Access_Framework_Groups_w_ID_Source.csv"
$TargetGroups = Import-Csv -Path "$FilePath\Conditional_Access_Framework_Groups_w_ID_Target.csv"

# Create a hashtable to store the old and new ID values
$GroupMap = @{}
foreach ($i in 0..($SourceGroups.Count-1)) {
  # For each pair of source and target groups, add their IDs to the hashtable
  $GroupMap[$SourceGroups[$i].Id] = $TargetGroups[$i].Id
}

# Ask for the JSON files folder path
$JsonFilesPath = Read-Host -Prompt "Enter the folder path for the JSON files"

# Get the JSON files from the folder
$JsonFiles = Get-ChildItem -Path "$JsonFilesPath" -Filter "*.json"

# Loop through each JSON file
foreach ($JsonFile in $JsonFiles) {
  # Convert the JSON content to a PowerShell object
  $JsonContent = Get-Content -Path $JsonFile.FullName -Raw | ConvertFrom-Json

  # Loop through each excludeGroup value in the conditions.users.excludeGroups property
  for ($i = 0; $i -lt $JsonContent.conditions.users.excludeGroups.Count; $i++) {
    $ExcludeGroup = $JsonContent.conditions.users.excludeGroups[$i]

    # Check if the excludeGroup value exists in the hashtable keys
    if ($GroupMap.ContainsKey($ExcludeGroup)) {
      # Replace the excludeGroup value with the corresponding hashtable value
      $JsonContent.conditions.users.excludeGroups[$i] = $GroupMap[$ExcludeGroup]
    }
  }

  # Loop through each includeGroup value in the conditions.users.includeGroups property
  for ($i = 0; $i -lt $JsonContent.conditions.users.includeGroups.Count; $i++) {
    $IncludeGroup = $JsonContent.conditions.users.includeGroups[$i]

    # Check if the includeGroup value exists in the hashtable keys
    if ($GroupMap.ContainsKey($IncludeGroup)) {
      # Replace the includeGroup value with the corresponding hashtable value
      $JsonContent.conditions.users.includeGroups[$i] = $GroupMap[$IncludeGroup]
    }
  }

  # Convert the PowerShell object back to JSON and overwrite the file
  $JsonContent | ConvertTo-Json -Depth 4 | Set-Content -Path $JsonFile.FullName
}

Write-Host ""
Write-Host "Prepared the exported Conditional Access JSON Files with new Group IDs from the Groups of the Target Tenant" -ForegroundColor Magenta

Write-Host ""
Write-Host "Done."