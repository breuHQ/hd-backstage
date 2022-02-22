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

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.8.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.1.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }

  backend "gcs" {
    bucket = "hd-backstage-poc-terraform-state"
  }
}

provider "external" {}
provider "local" {}
provider "null" {}
provider "random" {}
provider "template" {}

provider "google" {
  project = "hd-backstage-poc-28107"
  region  = "europe-west3"
}

provider "google-beta" {
  project = "hd-backstage-poc-28107"
  region  = "europe-west3"
}
