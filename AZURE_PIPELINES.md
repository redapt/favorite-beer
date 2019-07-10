# Azure DevOps Pipelines

The `azure-pipelines.yml` file is setup to perform a docker build and then push to azure container registry.

Before this pipeline can be run, there are some pre-requisites.

## Pre-Requisites

### Azure Container Registry

Can be easily created via the Azure portal, or another scripting framework like Terraform or ARM.

In this case, we have set up a `redaptdemo` acr for the purposes of testing this build functionality.

### Service Principal with Access To Registry

The service principal can be created via `Azure Active Directory`.

Under this, select `App Registrations`, and create a registration.

Inside this new app registration, grab the object id, client id, and tenant id from the overview page.

In this case our values are: 

Object ID: `cf01ff65-fdef-4266-9d3e-449bc745bdb5`
Client ID: `900e0e26-2ba8-4146-b21d-a571fd463f6e`
Tenant ID: `116e9905-19fc-428e-93d4-bcaffb833597`

Now, under the Certificates & Secrets tab, select `New Client Secret`, give it an expiration and accurate description. Once you have done that, the secret value will appear inline under Client Secrets table. If you leave this blade, this value wont be printed again. We will need this value later, when configuring Azure DevOps pipeline.

#### Assign Permissions to the Service Principal

In the Azure portal, navigate to the ACR resource and select `Access Control (IAM)`.

On the `Role Assignments` tab, click `Add`, select the AcrPush role, and then in the select box, type the name of the Service Principal specified during app registration above. In this case our service principal is `jm-devops`. Click `Save`.

That should be sufficient for the demo.

### Populate Azure DevOps pipeline Variables

In the `azure-pipelines.yml` we have specified a login command, to that Service Principal, using secrets that are set in the Azure DevOps side.

```
ARM_TENANT_ID: $(ext_variable_arm_tenant_id)
ARM_CLIENT_ID: $(ext_variable_arm_client_id)
```
After connecting as the service principal, we login to the ACR, and begin our docker push operations.

In Azure DevOps, navigate to the appropriate pipeline, and select `Edit`. After doing so, you will see a Run button in the top right, you will want to click the elipses to the right of that, to open the dropdown and select `Variables`.

On this page, we can populate the variables that are not sensitive.

ext_variable_arm_tenant_id = 116e9905-19fc-428e-93d4-bcaffb833597
ext_variable_arm_client_id = 900e0e26-2ba8-4146-b21d-a571fd463f6e

### Create an Azure Keyvault to Store Secret Variables

In the Azure Portal, create a Key Vault, in this case we named our `redaptdemo`.

Click into the key vault, and select the `Secrets` tab. 

Click `Generate/Import` at the top of the new blade. Create the secret named `arm-client-secret`, and put the client secret obtained above as the value. Click `Create`.

#### Create the Variable Group on the Pipeline to Reference the Keyvault

Navigate to the `Variables` page for the chosen pipeline, as defined above. This time choose, `Variable Groups` tab on the left, then select `Manage variable groups`, and then `+ Variable Group`.

In our case, we named the Variable group, `redaptdemo`. Select `Link secrets from an Azure key Vault as variables`.

Choose your Azure Subscription from the new drop down, and if not already, click `Authorize`.

Under Key Vault name, choose the keyvault we created in the previous step, and if not already, click `Authorize`. This will setup permissions on the keyvault, for Azure Devops to use it.

Under the `Variables` section, at the bottom, click `+ Add` and select `arm-client-secret` to link this variable and then select `Save`.

Navigate back to the `Variable groups` page on the variables tab of the pipeline. Select `Link variable group` and choose our newly created `redaptdemo` group. Click the save dropdown, and select `Save`.

In the azure-pipelines.yml file, we have included the group as part of our pipeline variables, as well as a single statically defined variable.

```
variables:
- group: redaptdemo
- name: variable_acr_name
  value: 'redaptdemo'
```

