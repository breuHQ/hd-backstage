resource "google_artifact_registry_repository" "backstage" {
  provider      = google-beta
  project       = var.project
  location      = var.region
  repository_id = local.computed_name
  format        = "DOCKER"

  labels = {
    application = "backstage"
    environment = "poc"
  }
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.backstage_gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.backstage_gke.ca_certificate)
}

module "backstage_gke" {
  source                    = "github.com/terraform-google-modules/terraform-google-kubernetes-engine.git//modules/private-cluster?ref=v17.3.0"
  project_id                = var.project
  name                      = local.computed_name
  region                    = var.region
  network                   = google_compute_network.backstage.name
  subnetwork                = google_compute_subnetwork.backstage.name
  ip_range_pods             = "${local.computed_name}-gke-pods"
  ip_range_services         = "${local.computed_name}-gke-services"
  create_service_account    = false
  service_account           = google_service_account.backstage.email
  default_max_pods_per_node = 32
  enable_private_nodes      = true
  master_ipv4_cidr_block    = "10.1.1.0/28"

  node_pools = [
    {
      name               = "${local.computed_name}-node-pool"
      machine_type       = "e2-medium"
      min_count          = 1
      max_count          = 8
      local_ssd_count    = 0
      disk_size_gb       = 10
      disk_type          = "pd-ssd"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = google_service_account.backstage.email
      preemptible        = false
      initial_node_count = 1
      preemptible        = true
    },
  ]

  cluster_resource_labels = {
    application = "backstage"
    environment = "poc"
  }

  node_pools_labels = {
    all = {
      application = "backstage"
      environment = "poc"
    }
  }
}

