# Conditional Access Sample Policies for Zero Trust

![Alt text](readme_headline.png)

## Folder Purpose
This subfolder contains all the Conditional Access policies exported from my lab environment using the scripts provided in this repository. These policies are prepped for importing into another tenant.

## Policies Origin
These policies were manually created by @philippkohn](https://github.com/philippkohn) in a Contoso Test Environment. They were subsequently exported using the scripts located in the `/Scripts` folder of this repository.

For further information about the Framework, please refer to:
- [ConditionalAccessGovernanceAndPrinciplesforZeroTrust May 2022.pdf](<../ConditionalAccessGovernanceAndPrinciplesforZeroTrust May 2022.pdf>)

For a visualized version, please view these slides:
- [Conditional Access for Zero Trust - Philipp Kohn - 11-08-13.ppsx](<https://view.officeapps.live.com/op/view.aspx?src=https%3A%2F%2Fraw.githubusercontent.com%2Fphilippkohn%2FConditionalAccessforZeroTrustResources%2Fmain%2FConditional%2520Access%2520for%2520Zero%2520Trust%2520-%2520Philipp%2520Kohn%2520-%252011-08-13.ppsx&wdOrigin=BROWSELINK>)

## Policy Count
As of the last documentation, there are 52 exported policies located in `/ConditionalAccessSamplePolicies/M365x77476191.onmicrosoft.com-08-18-2023`.

## Policy Format
All policies are provided in the JSON format.

## Usage Instructions
These policies can be imported either manually via the Microsoft Entra Admin Center Webinterface or using the scripts provided in this repository.

## Safety & Precautions 
Please exercise caution when implementing these policies. Always test the Conditional Access Sample Policies in your Microsoft 365 Test Tenant before deploying them to production. Remember to maintain a Break Glass Account and be vigilant to avoid locking yourself out ⚠️.

## Customization
You can import these policies into your Test Tenant, customize them as needed, and then export them for further use. For documentation purposes, the Conditional Access Documenter from idpowertoys.com is recommended.

## Dependencies
To import these policies into your tenant, utilize the scripts provided in the `/Scripts` directory of this repository.

## Updates & Revisions
Currently, there are no plans for major releases or updates to these policies.

## Feedback & Contributions
Connect with me on Twitter [@philipp_kohn](https://twitter.com/philipp_kohn) or on [LinkedIn](https://www.linkedin.com/in/philippkohn/). As this is a community-driven project, please understand that responses may not always be immediate.
