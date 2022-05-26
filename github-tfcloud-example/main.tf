terraform {
    cloud {
      organization = "nr-tf-cloud"
      workspaces {
        name = "nr-tf-cloud"
      }
    }
    required_providers {
        newrelic = {
        source  = "newrelic/newrelic"
        version = "~> 2.39.2"
      }
    }
}


provider "newrelic" {}
# Configuration provided via env vars

variable "NEW_RELIC_REGION" {
  type    = string
  default = "US"
}

variable "NEW_RELIC_ACCOUNT_ID" {
  type    = string
}

variable "NEW_RELIC_API_KEY" {
  type    = string
}

resource "newrelic_alert_policy" "workflowtest" {
  name = "Example TerraformCloud Workflow"
  incident_preference = "PER_POLICY" 
}