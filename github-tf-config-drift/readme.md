# New Relic TerraformConfiguration Drift Workflow
This example demonstrates how a scheduled Github action may trigger a Terraform plan and report the data to New Relic where an alert could be setup to trigger a response. It also demonstrates how you might attempt auto-remediation.


## Setup:
Copy all the files from the project to your own repo and configure accordingly as described below.

### 1. Configure State
In this example the terraform state file is stored in S3. You will need to create the S3 bucket and give permissions to an IAM role to write and read from the bucket. 

Update main.tf with your `bucket` name where indicated and set the `key` as your desired folder/filename for the state file. Set the `region` as appropriate.

### 2. Configure worfklows
The workflow is defined in the [.github](./.github) folder. If you main branch is not called "main" you will need to update the workflow accordingly.

If you wish to attempt to auto remediate then uncomment the apply section of the workflow.

To run the github workflows you need to setup the following environment variable secrets in GitHub in the UI:

- AWS_ACCESS_KEY_ID - the access key ID for an AWS IAM user that allows terraform state to be stored in specified S3 bucket
- AWS_SECRET_ACCESS_KEY - the key for the above 
- NEW_RELIC_ACCOUNT_ID - Your New Relic account ID
- NEW_RELIC_API_KEY - Your New Relic User API Key
- NEW_RELIC_INGEST_API_KEY - A New Relic ingest key, for sending Metric data regarding the plan to New Relic

## Testing
You can test by uncommenting the `workflow_dispatch:` option in the configuration, this allows you to manually run the action on demand. You may also adjust the schedule to run more frequently.

You can view the latest changes reported to New Relic with the following NRQL query:

```
SELECT latest(`tf-drift-check`) from Metric
```

Or to view all the data:
```
SELECT * from Metric where metricName='tf-drift-check'
```