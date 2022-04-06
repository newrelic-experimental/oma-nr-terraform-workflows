terraform {
  required_version = "~> 1.1.7"
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 2.22.1"
    }
  }
}
provider "newrelic" {
  region = "US"                   
}

terraform {
  backend "s3" {
    bucket = "YOUR-S3-BUCKET-NAME-HERE"
    key    = "YOUR-S3-STATE-FOLDER/YOUR-STATE-FILENAME.tfstate"
    region = "eu-west-2"
    profile = "default"
  }
}

# --- Actual new relic terraform here, try changing the policy name!

resource "newrelic_alert_policy" "workflowtest" {
  name = "Example Github Config Drift Policy"
  incident_preference = "PER_POLICY" 
}