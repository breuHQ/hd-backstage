resource "google_artifact_registry_repository" "backstage_backend" {
  provider      = google-beta
  project       = var.project
  location      = var.region
  repository_id = "backstage-backend"
  format        = "DOCKER"

  labels = {
    application = "backstage"
    environment = "poc"
  }
}

resource "google_artifact_registry_repository" "backstage_frontend" {
  provider      = google-beta
  project       = var.project
  location      = var.region
  repository_id = "backstage-frontend"
  format        = "DOCKER"
}
