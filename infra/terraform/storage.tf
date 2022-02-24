resource "google_storage_bucket" "backstage_docs" {
  project  = var.project
  location = "EU"
  name     = local.storage__docs__name
}
