# Check PowerShell Version
if ($PSVersionTable.PSVersion.Major -lt 7) {
  Throw "This script requires PowerShell 7 or a newer version."
}

# Get the source and target group mappings from the CSV files
$SourceGroups = Import-Csv -Path "C:\Scripts\M365\Conditional Access Framework\Conditional_Access_Framework_Groups_w_ID_Source.csv"
$TargetGroups = Import-Csv -Path "C:\Scripts\M365\Conditional Access Framework\Conditional_Access_Framework_Groups_w_ID_Target.csv"

# Create a hashtable to store the old and new ID values
$GroupMap = @{}
foreach ($i in 0..($SourceGroups.Count-1)) {
  $GroupMap[$SourceGroups[$i].Id] = $TargetGroups[$i].Id
}

# Get the JSON files from the folder
$JsonFiles = Get-ChildItem -Path "C:\Scripts\M365\Conditional Access Framework\M365x77476191.onmicrosoft.com-07-10-2023" -Filter "*.json"

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
