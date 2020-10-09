# sfdx-data-mask-compliance

This is an SFDX project that contains a solution that extends Data Mask functionality to support sandbox compliance approval processes by: 

1. Matching fields with Compliance Categorization to Data Mask configurations
2. Pushing Data Mask Run Logs to Production 





## Development

To work on this project in a scratch org:

1. [Set up CumulusCI](https://cumulusci.readthedocs.io/en/latest/tutorial.html)
2. Run `cci flow run dev_org --org dev` to deploy this project.
3. Run `./scripts/assign-perm-set-to-user.sh` to assign permission set **RC_Data_Mask_Compliance** to the scratch org user. 
4. Run `cci org browser dev` to open the org in your browser.