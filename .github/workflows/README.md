# Secrets

## Deployment to dev sandboxes

SFDX Auth Url for dev sandboxes, which can be manually or automatically deployed when creating new packages. These sandboxes should be unique for each team or repo. See how to create [SFDX Auth URL](#SFDX-Auth-URL) below.

- DEV_SFDX_URL `[OPTIONAL]`
- DEPLOY_TO_DEV_AFTER_PACKAGE_CREATION `[OPTIONAL, VALID VALUES ARE 1 OR 0]`
- DEPLOY_TO_UAT_AFTER_PACKAGE_CREATION `[OPTIONAL, VALID VALUES ARE 1 OR 0]`

```java
   1 // auto-deploy to the respective sandbox
   0 // will NOT auto-deploy
null // will NOT auto-deploy if the secret is not set
```

# SFDX Auth URL

Use the following command to get a SFDX Auth URL (see value for `Sfdx Auth Url`):

```bash
sfdx force:org:display -u [ORG_ALIAS] --verbose
```

Source: [Create your own SFDX Auth Url](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_auth_view_info.htm)
