# sfdx-data-mask-compliance



## Development

To work on this project in a scratch org:

1. [Set up CumulusCI](https://cumulusci.readthedocs.io/en/latest/tutorial.html)
2. Run `cci flow run dev_org --org dev` to deploy this project.
3. Run `./scripts/assign-perm-set-to-user.sh` to assign permission set **RC_Data_Mask_Compliance** to the scratch org user. 
4. Run `cci org browser dev` to open the org in your browser.