terraform {
  required_version = "1.1.7"

  required_providers {
    google      = ">= 4.0.0, < 5.0.0"
    google-beta = ">= 4.0.0, < 5.0.0"
    kubernetes  = ">= 2.8.0"
    local       = ">= 2.1.0"
    null        = ">= 3.1.0"
    random      = ">= 3.1.0"
  }

  backend "gcs" {
    bucket = "hd-backstage-poc-terraform-state"
  }
}
