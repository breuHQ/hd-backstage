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