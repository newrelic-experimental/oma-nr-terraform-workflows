# New Relic Terraform Workflow: Circle CI Pipeline Example
This project demonstrates a simple Circle CI pipeline workflow to control New Relic terraform updates.

When a PR is created the terraform plan workflow is triggered. When the PR is merged to main branch the terraform apply is triggered making the actual changes. Merge rights to the main branch should therefore be restricted to specific users.

## Setup
These steps will help you setup a Circle CI powered New Relic Terraform workflow on a new Github project. Adjust accordingly for pre-existing projects or other code management systems.

### 1. Configure State
In this example the terraform state file is stored in S3. You will need to create the S3 bucket and give permissions to an IAM role to write and read from the bucket.

- Copy `main.tf` from this folder into your Circle CI repo. 
- Copy `.circleci` fodler from this folder into your Circle CI repo. This contains the Circle CI configuration. 
- In `main.tf` update the `backend` configuration block with your `bucket` name where indicated and set the `key` as your desired folder/filename for the state file. Set the `region` as required.
- Commit and push the repo. 

> The main.tf includes a single new relic alert policy resource for testing.

### 2. Create the Deployment Pipeline
We need to setup a deployment pipeline to run terraform.

- In Circle CI, navigate to `Organization -> Projects` section setup the connection to your GitHub repository

- Ensure "Only build pull requests" is enabled in `Project -> Project Settings -> Advanced`

### 3. Configure the pipeline
In order to make changes to New Relic the pipeline requires New Relic user API keys ,and to store the state in AWS it needs access tokens. These are provided via deployment variables.

Navigate to `Project -> Project Settings -> Environment Variables` and add the following variables:

- `AWS_ACCESS_KEY_ID` - the access key ID for an AWS IAM user that allows terraform state to be stored in specified S3 bucket
- `AWS_SECRET_ACCESS_KEY` - the key for the above
- `NEW_RELIC_ACCOUNT_ID` - Your New Relic account ID
- `NEW_RELIC_API_KEY` - A New Relic User API Key

### 4. Test Workflow
We can now test the full workflow by making a change, raising then merging a PR:

- Create a new branch and change the name of the policy in `main.tf`. 
- Commit the change and make a pull request.
- Observe the pipeline ran, you can see the plan output in the pipeline log.
- Merge the pull request.
- Observe the pipeline runs from where it left off, running only apply with plan obtained previous stage ( during PR ).
- Observe the changes are made to your New Relic alert policy as expected.

### 5. Auto apply on merge
The apply operation is currently automatically triggered on merge. If you prefer to approve apply operations within CircleCI then add `type: approval` to apply workflow for manual approval e.g.

```
- apply:
  type: approval
  requires:
    - plan
    filters:
    branches:
        only: main
```







