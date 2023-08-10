Conditional Access for Zero Trust - Sample Policies
-----------------------------------------------------
Instead of Microsoft365DSC, I decided to use Microsoft Graph PowerShell Scripts.
Because I find Microsoft365DSC too cumbersome in daily business.

In the **directory [M365x77476191.onmicrosoft.com-08-10-2023](https://github.com/philippkohn/ConditionalAccessforZeroTrustResources/tree/main/ConditionalAccessSamplePolicies/M365x77476191.onmicrosoft.com-08-10-2023)** are example policies that are based on the Conditional Access Framework for Zero Trust Framework from "Microsoft - Claus Jespersen" and largely adhere to the framework guidelines.

> **Disclaimer**
> - Please test the Conditional Access Sample Policies in your Microsoft 365 Dev Environment before Production use!
> - Use a Break Glass Account - Don't shoot yourself in the foot ⚠️

Change Log
-----------------------------------------------------
- Using only one exclusion Group per Persona
- ...
- ...
- To be completed

Further Information
-----------------------------------------------------
*See more here for a description on CA configured for Zero Trust*
- [Conditional Access for Zero Trust - Azure Architecture Center | Microsoft Learn](https://learn.microsoft.com/en-us/azure/architecture/guide/security/conditional-access-zero-trust)
- [Conditional Access framework and policies - Azure Architecture Center | Microsoft Learn](https://learn.microsoft.com/en-us/azure/architecture/guide/security/conditional-access-framework)
- [Readme of the original repo using Microsoft365DSC](https://github.com/microsoft/ConditionalAccessforZeroTrustResources/blob/main/ConditionalAccessSamplePolicies/readme.md)