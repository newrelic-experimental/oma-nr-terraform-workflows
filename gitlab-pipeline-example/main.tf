# terraform and New Relic provider version config 
terraform {
  required_version = "~> 1.1.3"
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 2.39.2"
    }
  }
}
provider "newrelic" {}
# Configuration provided via env vars
# For details of supported env vars see: https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/guides/provider_configuration 

#Define backend as http
terraform {
  backend "http" {
  }
}

# Example of required input variable 
# this will be supplied a value via the env var TF_VAR_AlertAccountId
variable "AlertAccountId" { 
    type = string 
}

# Example New Relic resources - an alert policy and a condition
resource "newrelic_alert_policy" "policy" {
  name = "Terraform policy - GITLAB"
  incident_preference = "PER_POLICY" 
}
resource "newrelic_nrql_alert_condition" "nrql_condition" {
  account_id                   = var.AlertAccountId
  policy_id                    = newrelic_alert_policy.policy.id
  type                         = "static"
  name                         = "Example NRQL Condition"
  enabled                      = true
  violation_time_limit_seconds = 3600

  fill_option          = "static"
  fill_value           = 0

  aggregation_window             = 30
  expiration_duration            = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = 0


  nrql {
    query             = "select count(*) from Transaction where error is true"
  }

  critical {
    operator              = "above"
    threshold             = 5
    threshold_duration    = 60
    threshold_occurrences = "at_least_once"
  }

  warning {
    operator              = "above"
    threshold             = 2
    threshold_duration    = 60
    threshold_occurrences = "at_least_once"
  }

}
