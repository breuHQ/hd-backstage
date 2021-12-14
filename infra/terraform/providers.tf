terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.57.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.57.0"
    }
  }
}

provider "google" {
  project = "hd-backstage-poc-28107"
  region  = "europe-west3"
}

provider "google-beta" {
  project = "hd-backstage-poc-28107"
  region  = "europe-west3"
}
