terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0, < 5.0.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.0.0, < 5.0.0"
    }
  }

  backend "gcs" {
    bucket = "hd-backstage-poc-terraform-state"
  }
}

provider "random" {}
provider "null" {}
provider "external" {}
provider "template" {}
provider "local" {}

provider "google" {
  project = "hd-backstage-poc-28107"
  region  = "europe-west3"
}

provider "google-beta" {
  project = "hd-backstage-poc-28107"
  region  = "europe-west3"
}
