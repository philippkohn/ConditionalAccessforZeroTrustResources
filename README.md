# Persona Based Conditional Access Framework for Zero Trust

![Alt text](Readme_Headline.png)

## Project Overview

I am a Microsoft 365 and Microsoft Entra Consultant and an enthusiast of the Persona Based Conditional Access Framework for Zero Trust by [@clajes](https://github.com/clajes). Having manually created over 50 policies, I sought an uncomplicated way to deploy them across other Microsoft Entra Tenants. Rather than using Microsoft365DSC, I crafted my own solution, delving deep into the Microsoft Graph PowerShell SDK in the process.

## Repository Structure

- `/ConditionalAccessSamplePolicies`: This subfolder contains all the Conditional Access policies exported from my lab environment using the scripts provided in this repository. These policies are prepped for importing into another tenant.
- `/Scripts/`: Here, you'll find all the scripts to export and import Conditional Access policies for your tenant.

## Getting Started

Please start by setting up a Microsoft 365 Test/Lab environment to test the provided scripts. Exercise caution when using these scripts to avoid locking yourself out! Note that these scripts are provided without any warranties.

For further information about the Framework, please refer to:
- [ConditionalAccessGovernanceAndPrinciplesforZeroTrust May 2022.pdf](<../ConditionalAccessGovernanceAndPrinciplesforZeroTrust May 2022.pdf>)

For a visualized version, please view these slides:
- [Conditional Access for Zero Trust - Philipp Kohn - 11-08-13.ppsx](<https://view.officeapps.live.com/op/view.aspx?src=https%3A%2F%2Fraw.githubusercontent.com%2Fphilippkohn%2FConditionalAccessforZeroTrustResources%2Fmain%2FConditional%2520Access%2520for%2520Zero%2520Trust%2520-%2520Philipp%2520Kohn%2520-%252011-08-13.ppsx&wdOrigin=BROWSELINK>)

**Target Audience**: Primarily tailored for Microsoft 365 Admins and Microsoft Entra Admins.

## Project Dependencies

This project leverages the Microsoft Graph PowerShell SDK and requires PowerShell 7.x (Core) for execution.

## Contributors & Acknowledgments

Special thanks to:
- [@clajes](https://github.com/clajes) for his foundational Conditional Access Framework for Zero Trust.
- [@merill](https://github.com/merill) for the idpowertoys.com toolkit, which was invaluable during the creation of this repository.

## Versioning & Releases

Currently, there are no plans for new major releases.

## Feedback & Contributions

You can connect with me on Twitter [@philipp_kohn](https://twitter.com/philipp_kohn) or on LinkedIn [here](https://www.linkedin.com/in/philippkohn/). As this is a community project, I appreciate your understanding if responses are not immediate.

## Licensing & Usage Rights

This project adheres to the licensing of the original repository. For details, please refer to the LICENSE information within the repo.

## Future Roadmap

At present, there are no plans for new major releases or updates.

