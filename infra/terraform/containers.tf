resource "google_artifact_registry_repository" "backstage_backend" {
  provider      = google-beta
  project       = var.project
  location      = var.region
  repository_id = "backstage-backend"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "backstage_frontend" {
  provider      = google-beta
  project       = var.project
  location      = var.region
  repository_id = "backstage-frontend"
  format        = "DOCKER"
}
