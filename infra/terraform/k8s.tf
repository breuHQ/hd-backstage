resource "google_artifact_registry_repository" "backstage_backend" {
  provider      = google-beta
  project       = var.project
  location      = var.region
  repository_id = "${local.computed_name}-backend"
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
  repository_id = "${local.computed_name}-frontend"
  format        = "DOCKER"

  labels = {
    application = "backstage"
    environment = "poc"
  }
}

# module "k8_backstage_cluster" {
#   source = "../../../../breu/terraform/terraform-gcp-kubernetes"

#   project   = var.project
#   name      = local.computed_name
#   namespace = "backstage"
# }
