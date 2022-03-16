# New Relic Terraform Workflow: Github Actions Example
This project demonstrates a simple github actions workflow to control New Relic terraform updates.

When a PR is created the terraform plan workflow is triggered, the output of the plan is added as a comment to the PR. When the PR is merged to main branch the terraform apply is triggered making the actual changes. Merge rights should therefore be restricted to specific users. 


## Setup:
Copy all the files from the project to your own repo and configure accordingly as described below.

### 1. Configure State
In this example the terraform state file is stored in S3. You will need to create the S3 bucket and give permissions to an IAM role to write and read from the bucket. 

Update main.tf with your `bucket` name where indicated and set the `key` as your desired folder/filename for the state file. 

### 2. Configure worfklows
The workflows are defined in the [.github](./.github) folder. If you main branch is not called "main" you will need to update the workflows accordingly.

To run the github workflows you need to setup the following environment variable secrets in GitHub in the UI:

- AWS_ACCESS_KEY_ID - the access key ID for an AWS IAM user that allows terraform state to be stored in specified S3 bucket
- AWS_SECRET_ACCESS_KEY - the key for the above 
- NEW_RELIC_ACCOUNT_ID - Your New Relic account ID
- NEW_RELIC_API_KEY - Your New Relic User API Key

## Testing
Pushing the main branch will trigger the terrafrom apply workflow. Observe that the actions run correctly and that a policy named "Example Github Workflow" appears in your New Relic account.

To test the PR/Merge proces:
1. Create a new branch and make a change to the policy name. 
2. Commit the change and create pull request to main branch. 
3. Observe that the workflow runs and reports the change to PR thread. 
4. Merge the change to main branch
5. Observe that the apply workflow runs and that the policy is updated in New Relic UI.