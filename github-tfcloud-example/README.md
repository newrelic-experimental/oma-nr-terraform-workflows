# New Relic Terraform Workflow: Terraform Cloud Pipeline Example
This project demonstrates a simple Github Action pipeline that dirves Terraform Cloud to perform New Relic terraform updates.

When a PR is created the github action workflow is triggered and terraform plan is triggered.
When the PR is merged to the main branch the terraform apply is triggered making the actual changes. 

Merge rights to the main should therefore be restricted to specific users.

## Setup
These steps will help you setup a Github Action & Terraform Cloud workflow on a new project. Adjust accordingly for pre-existing projects.

### 1. Link Terraform Cloud to Github

Navigate to `Terraform Cloud -> User Settings -> Tokens -> Create API Token` take note API key created.
On Github navigate to `Repository Settings -> Secrets -> New Repository Secret` name your secret TF_API_TOKEN and use the API obtained in previous step as value.


### 2. Configure Terraform Cloud
In this example the terraform state file is stored in Terraform Cloud. 
In order to make changes to New Reli, Terraform Cloud requires New Relic API key and New Relic Account ID. These are prodvided as deployment variables in Terraform Cloud.

Navigate to `Terraform Cloud -> Workspace -> Workspace Settings -> Environment Variables` and add the following variables:

- `NEW_RELIC_ACCOUNT_ID` - Your New Relic account ID
- `NEW_RELIC_API_KEY` - A New Relic User API Key

- Copy `main.tf` from this folder to root of your repo. 
- In `main.tf` update the `cloud` configuration block with your `organization` and `workspace` names.
- Set the New Relic `region` as required.
- Commit and push the repo. 

> The main.tf includes a single new relic alert policy resource for testing.

### 3. Configure Github action pipeline
- Copy `.github` folder from this folder to root of your repo. 
- In `.github/workflows/nr-tf-cloud.yml` update the `name` and `TF_WORKSPACE` with your Terraform Cloud workspace name, which was also used in step 2.

### 4. Test Workflow
We can now test the full workflow by making a change, raising then merging a PR:

- Create a new branch and change the name of the policy in `main.tf` to something new. 
- Commit the change and make a pull request.
- Observe the pipeline ran, you can see the plan output in the pipeline log.
- Merge the pull request.
- Observe the pipeline runs from where it left off, running only apply with plan obtained previous stage ( during PR ).
- Observe the changes are made to your New Relic alert policy as expected.

### 5. Auto apply on merge
Deployments are currently automatically triggered.



