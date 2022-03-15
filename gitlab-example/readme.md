# New Relic Terraform Workflow Example (Gitlab)
This example project shows how you can use GitLab CI/CD pipelines to automate your New Relic terraform workflow. It demonstrates using Gitlab managed terraform state and how to provide input variables to your terraform configuration.

The basic [terraform workflow](https://www.terraform.io/intro/core-workflow) is:
1. Create a change in a new branch
2. Create a merge request (Pipeline runs terraform plan)
3. Merge request (Pipeline runs terraform apply)


## Setup instructions
In this example we utilise Gitlab's terraform state storage solution. This stores the terraform state file with your project. When you create a merge request the Gilab pipeline will trigger a terraform plan. When you merge changes to the main branch the terraform apply will run.

> Note: this workflow assumes you main branch is called 'main'. If not you will need to adjust .gitlab-ci.yml accordingly.

### Step 1: Create the project and setup variables
1. If you do not already have one, create a project in GitLab and copy all the files from this repo into it. Make sure to copy `main.tf` and the hidden files  `.gitlab-ci.yml` and `.gitignore` files **but not** the `.git` folder.
2. In your Gitlab project under Settings -> CI/CD -> Variables create the following environment variables:
    - `NEW_RELIC_ACCOUNT_ID`:  Set this to your New Relic account ID, **do not enable protection or masking.**
    - `NEW_RELIC_API_KEY`: Set this to your New Relic User API Key. **Enable masking but not protection.**
    - `TF_VAR_AlertAccountId`: Set this to your New Relic account ID, **do not enable protection or masking.** This is to domnostrate how you pass input variable `AlertAccountId` to your configuration.
3. Decide on your STATE-NAME: This can be anything you like, you can have different names for different environments. You could simply choose `newrelic-state`.
4. Update [.gitlab-ci.yml](.gitlab-ci.yml) with your chosen STATE-NAME where shown. This is in two places:
    - `TF_ADDRESS` (line #5)
    - `cache -> key` (line #8)
5. Commit all the files and push to Gitlab:
```
git add .
git commit -m "init"
git push
```

### Step 2: Verify the pipeline
Pushing the main branch will cause the pipeline to run. 
1. Verify under CI/CD -> Pipelines that the pipeline has run without errors. Correct any errors and re-run if necessary.
2. If its worked it will have run the terraform plan but not the terraform apply. The apply step is currently configured to be manually run. Run the apply step in Gitlab UI and verify the alert policy is created successfully in your New Relic account.
3. Observe in Gitlab under Infrastructure -> Terraform that the state file is present

### Step 3: Test the PR pipeline process:
1. Create a new branch on your local machine: `git checkout -b "change1"`
2. Make a change to the terraform configuration in [main.tf](main.tf) (e.g. change the policy name). 
3. Commit and push the branch to Gitlab: 
```
git commit -a -m "Policy name changed"
git push --set-upstream origin change1
```
5. In Gitlab create a merge request for the branch you just pushed. 
6. Observe the pipeline runs up to and including the plan stage successfully. (This might take some time, hang in there.)
7. Once the pipline has finished, in Gitlab merge the merge request to main branch.
8. Observe the pipeline rstarts again but pauses at the apply stage.
9. Execute the apply in the deploy stage of the pipeline and observe the changes made in your New Relic account.

> Note: You can enable auto-execution of the terraform apply, see below.


### Step 4: (OPTIONAL) Initialise terraform backend for local development
If you want to be able to work locally then you need to ensure you local terraform knows how to acces the state stored in Gitlab.

1. Find your projects PROJECT-ID: This can be found on Settings -> General, it is a number.
2. If you dont already have one, generate a personal access token in Gitlab for your user with `api` scope.
3. Update the following command with your PROJECT-ID, STATE-NAME, GitLab USERNAME and ACCESS-TOKEN where approriate and run in your project folder:
```
terraform init \
    -backend-config="address=https://gitlab.com/api/v4/projects/<YOUR-PROJECT-ID>/terraform/state/<YOUR-STATE-NAME>" \
    -backend-config="lock_address=https://gitlab.com/api/v4/projects/<YOUR-PROJECT-ID>/terraform/state/<YOUR-STATE-NAME>/lock" \
    -backend-config="unlock_address=https://gitlab.com/api/v4/projects/<YOUR-PROJECT-ID>/terraform/state/<YOUR-STATE-NAME>/lock" \
    -backend-config="username=<YOUR-USERNAME>" \
    -backend-config="password=<YOUR-ACCESS-TOKEN>" \
    -backend-config="lock_method=POST" \
    -backend-config="unlock_method=DELETE" \
    -backend-config="retry_wait_min=5"
```

6. Test the configuration by running a terraform plan (or you could make a change and test an apply):
```
export NEW_RELIC_ACCOUNT_ID="YOUR-NR-ACCOUNT-ID"
export TF_VAR_AlertAccountId="YOUR-NR-ACCOUNT-ID"
export NEW_RELIC_API_KEY="YOUR-NR-USER-API-KEY"
terraform plan
```

## Automated terraform apply
If you want the terraform apply stage to execute automatically on merge instead of requiring manual intervention, then remove the `when: manual` attribute on the apply stage of [.gitlab-ci.yml](.gitlab-ci.yml)


## Resources
Refer to the Gitlab documentation for more information: [Gitlab Terraform State](https://docs.gitlab.com/ee/user/infrastructure/iac/terraform_state.html)

