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

# Get the source and target group mappings from the CSV files
$SourceGroups = Import-Csv -Path "C:\Scripts\Conditional_Access_Framework_Groups_w_ID_Source.csv"
$TargetGroups = Import-Csv -Path "C:\Scripts\Conditional_Access_Framework_Groups_w_ID_Target.csv"

# Ask the user to confirm if they have checked or changed the file path to the CSV for the mapping table
$Confirm = Read-Host -Prompt "Have you checked or changed, if necessary, the file path to the CSV-Files for the mapping table first? (y/n)"
# If the user answers yes, proceed with the script
if ($Confirm -eq "y") {
    # Do something with the source and target groups
}
# If the user answers no, exit the script
elseif ($Confirm -eq "n") {
    Write-Host "Please check or change the file path to the CSV-Files for the mapping table first and then run the script again." -ForegroundColor Cyan
    Exit
}
# If the user answers anything else, display an error message and exit the script
else {
    Write-Host "Invalid input. Please enter y or n." -ForegroundColor Red
    Exit
}

# Create a hashtable to store the old and new ID values
$GroupMap = @{}
foreach ($i in 0..($SourceGroups.Count-1)) {
  $GroupMap[$SourceGroups[$i].Id] = $TargetGroups[$i].Id
}

# Load the assemblies that contain the types needed for the folder browser dialog
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# Show a folder selection dialog box to select the folder containing the JSON files
$dialog = New-Object System.Windows.Forms.FolderBrowserDialog
$dialog.Description = "Select the folder containing the exported Conditional Access JSON files."
$dialog.ShowNewFolderButton = $false
$result = $dialog.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
  $JsonFiles = $dialog.SelectedPath

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
}