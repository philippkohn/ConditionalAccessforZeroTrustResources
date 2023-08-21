# README for Conditional Access Framework Scripts

## Introduction

![Alt text](Readme_Headline.png)

This repository contains a set of PowerShell scripts designed to manage and manipulate Microsoft Entra Conditional Access policies using the Microsoft Graph PowerShell SDK. These scripts streamline the process of exporting, modifying, and importing policies across different Microsoft tenants. Initially, they were written to export and import the policies for the Conditional Access Framework for Zero Trust by @clajes.

For further information about the Framework, please refer to:
- [ConditionalAccessGovernanceAndPrinciplesforZeroTrust May 2022.pdf](<../ConditionalAccessGovernanceAndPrinciplesforZeroTrust May 2022.pdf>)

For a visualized version, please view these slides:
- [Conditional Access for Zero Trust - Philipp Kohn - 11-08-13.ppsx](<../Conditional Access for Zero Trust - Philipp Kohn - 11-08-13.ppsx>)

**Target Audience**: Primarily tailored for Microsoft 365 Admins and Microsoft Entra Admins.

## Prerequisites

- PowerShell 7.x or newer.
- Microsoft Graph PowerShell SDK Modules 2.3.0 or newer installed
    - Microsoft.Graph.Applications
    - Microsoft.Graph.Authentication
    - Microsoft.Graph.Groups
    - Microsoft.Graph.Identity.Directory
    - Microsoft.Graph.Identity.Governance
    - Microsoft.Graph.Identity.SignIns
    - Microsoft.Graph.Identity.Users
- Creation of an App Registration in Azure AD for Authentication.

## Configuration

Ensure you have the following configurations set:

- Application (client) ID of the App Registration.
- Tenant IDs for your Azure AD.

## Scripts Overview

## Scripts Overview

### 1. Create Self-Signed Certificate

**Filename**: `00_ConditionalAccess_Framework_CreateSelfSigned_Certificate.ps1`

**Description**: Creates a self-signed certificate for use with Microsoft Graph PowerShell SDK Authentication and exports the public and private keys to files.

**Output**: Paths to the exported public and private key files.

---

### 2. Export Conditional Access Policies

**Filename**: `01_ConditionalAccess_Framework_Export_Policies.ps1`

**Description**: Exports Conditional Access policies from Microsoft Graph and saves them as individual JSON files. Note that the exported policies are set to a 'disabled' state to prevent potential lockouts.

---

### 3. Create Azure AD Groups

**Filename**: `02_ConditionalAccess_Framework_Create_Groups.ps1`

**Description**: Creates new Azure AD groups based on the names provided in a CSV file and outputs the group names and their corresponding IDs.

---

### 4. Export Azure AD Groups with IDs

**Filename**: `03_ConditionalAccess_Framework_Export_Groups_with_ID.ps1`

**Description**: Exports Azure AD groups and their associated IDs into a CSV file.

**Output**: CSV file containing group names and their corresponding IDs.

---

### 5. Prepare JSON Files with New Group IDs

**Filename**: `04_ConditionalAccess_Framework_Prepare_JSON_Files_w_new_Group_IDs.ps1`

**Description**: Updates the group IDs in JSON files for conditional access policies, preparing them for import into another tenant.

**Output**: Modified JSON files with updated group IDs.

---

### 6. Import Conditional Access Policies

**Filename**: `05_ConditionalAccess_Framework_Import_Policies.ps1`

**Description**: Imports Conditional Access policies from JSON templates into Microsoft Entra.


## Usage

1. Ensure you've met all the prerequisites mentioned above.
2. Clone this repository or download the scripts to your local machine.
3. Navigate to the directory containing the scripts.
4. Execute the scripts in the order of their numbering.
5. Always use this script in a Lab/Test/Dev Environment before deploying it to Production. It's crucial to import the Conditional Access Policy in a disabled state and use the "Report Only" mode in your Tenant for testing purposes. Be cautious and ensure you don't lock yourself out!

## Error Handling

Errors encountered during the execution of these scripts will be output to the Shell. Ensure you monitor the outputs for any potential issues.

## Updates, Support & Maintenance

- The scripts in this repository will be updated irregularly.
- This is a community-driven project. While updates will be given in a best-effort manner, there's no fixed support SLA.
- For any queries or assistance, you can reach out via Twitter: [@philipp_kohn](https://twitter.com/philipp_kohn).

## Related Resources

For a deeper dive into using PowerShell with the Microsoft Graph, visit [this Microsoft documentation](https://learn.microsoft.com/en-us/powershell/microsoftgraph/app-only?view=graph-powershell-1.0).

## Contribution

If you would like to contribute to this project or report any issues, please open a GitHub issue or submit a pull request.

## License

This project is licensed under the MIT License.
