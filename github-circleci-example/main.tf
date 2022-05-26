terraform {
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
    bucket = "dp-tf-states"
    key    = "terraform/circleci.tfstate"
    region = "eu-west-2"
    profile = "default"
  }
}

resource "newrelic_alert_policy" "workflowtest" {
  name = "Example CircleCI Workflow"
  incident_preference = "PER_POLICY" 
}
