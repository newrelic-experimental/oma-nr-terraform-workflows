# New Relic Terraform Workflow: Bitbucket Pipeline Example
This project demonstrates a simple Bitbucket pipeline workflow to control New Relic terraform updates.

When a PR is created the terraform plan workflow is triggered. When the PR is merged to main branch the terraform apply is triggered making the actual changes. Merge rights to the main should therefore be restricted to specific users.

## Setup
These steps will help you setup a New Relic Terraform workflow on a new project. Adjust accordingly for pre-existing projects.

### 1. Configure State
In this example the terraform state file is stored in S3. You will need to create the S3 bucket and give permissions to an IAM role to write and read from the bucket.

Copy `main.tf` from this folder into your Bitbucket repo. 

In `main.tf` update the `backend` configuration block with your `bucket` name where indicated and set the `key` as your desired folder/filename for the state file. Set the `region` as required.

Commit and push the repo. 

> The main.tf includes a single new relic alert policy resource for testing.

### 2. Create the Pipeline

In Bitbucket, navigate to `Repository Settigns -> Settings` section and enable pipelines.

Navigate to `Deployments` section of BitBucket. Copy and paste the contents of `bitbucket-pipelines.yml` here and commit. 

> Be sure to check the branch name is accurate in `bitbucket-pipelines.yml`, this guide assumes your main branch is called `main`, if not change accordingly.

Navigate to the `Pipelines` section and observe that the pipeline is running a security check.

### 3. Configure the pipeline
In order to make changes to New Relic the pipeline requires api keys and to store the state in AWS it needs access tokens. These are prodvided as deployment variables.

Navigate to the `bitbucket-pipelines.yml` file in Bitbucket and edit the file. On the right hand side add the following variables against the Production deployment environment:

- `AWS_ACCESS_KEY_ID` - the access key ID for an AWS IAM user that allows terraform state to be stored in specified S3 bucket
- `AWS_SECRET_ACCESS_KEY` - the key for the above
- `NEW_RELIC_ACCOUNT_ID` - Your New Relic account ID
- `NEW_RELIC_API_KEY` - A New Relic User API Key

### 4. Test Deploy Pipeline
Lets test the variables are all correct by initiaiting the deployment.

- Navigate to `Pipelines` and view the last run pipeline. 
- You should see that its paused at the 'Deploy' step. 
- Click the Deploy button to begin a deployment. This will run terraform apply.
- Observe the resource is created in New Relic

### 5. Configure workflow permissons
Its good practice to restrict which users can merge to main and thus trigger a terraform apply. Bitbucket provides branch permission controls to help with this.

- Navigate to `Repository Settings - > Branch Permissions`. 
- Add a branch permission. 
- Enter you branch name (`main`) and select which users have write and merge acess.
- Select the option "Check the last commit for at least [1] successful build and no failed builds" (This ensures merges will be prevented/warned if the terraform plan has failed)

### 6. Test Workflow
We can now test the full workflow by making a change, raising then merging a PR:

- Create a new branch and change the name of the policy in `main.tf`. 
- Commit the change and make a pull request.
- Observe the pipeline ran, you can see the plan output in the pipeline log.
- Merge the pull request.
- Observe the pipeline runs and pauses at the deploy stage.
- Trigger the deployment.
- Observe the changes are made to your New Relic alert policy as expected.

### 7. Auto apply on merge
Deployments are currently manually triggered. To automatically apply the terrform changes on merge remove `trigger: manual` from the deployment step in `bitbucket-pipelines.yml`





