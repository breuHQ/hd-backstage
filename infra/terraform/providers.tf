terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.3.0"
    }
  }
}

provider "google" {
  project = "hd-backstage-poc-28107"
  region  = "europe-west3"
}
