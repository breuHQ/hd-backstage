resource "google_storage_bucket" "backstage_docs" {
  project  = var.project
  location = "EU"
  name     = local.storage__docs__name

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "backstage_assets" {
  project  = var.project
  location = "EU"
  name     = local.storage__assets__name

  versioning {
    enabled = true
  }
}
