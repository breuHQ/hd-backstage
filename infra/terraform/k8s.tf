# ------------------------------------------------------------------------------
# CREATE DOCKER REGISTRY
# ------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------
# CREATE KUBERNETES CLUSTER AND PROVISION THE TERRAFORM PROVIDER
# ------------------------------------------------------------------------------

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
  ip_range_pods             = local.backstage_cluster_pods_ip_range_name
  ip_range_services         = local.backstage_cluster_services_ip_range_name
  create_service_account    = false
  service_account           = google_service_account.backstage.email
  default_max_pods_per_node = 64
  enable_private_nodes      = true
  master_ipv4_cidr_block    = "10.1.1.0/28"
  remove_default_node_pool  = true

  cluster_resource_labels = {
    application = "backstage"
    environment = "poc"
  }

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

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/sqlservice.admin",
    ]
  }
  node_pools_labels = {
    all = {
      application = "backstage"
      environment = "poc"
    }
  }
}

# ------------------------------------------------------------------------------
# ADD CONFIGURATION TO KUBERNETES CONFIG TO RUN `kubectl` COMMAND
# ------------------------------------------------------------------------------
resource "null_resource" "backstage_cluster_credentials" {
  depends_on = [
    module.backstage_gke.google_container_cluster,
  ]

  triggers = {
    clusters = "${module.backstage_gke.name}-${module.backstage_gke.endpoint}",
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${module.backstage_gke.name} --region ${var.region}"
  }
}

# ------------------------------------------------------------------------------
# PREPARE KUBERNETES CLUSTER TO RUN BACKSTAGE
# ------------------------------------------------------------------------------

resource "kubernetes_namespace" "backstage" {
  depends_on = [
    module.backstage_gke,
    null_resource.backstage_cluster_credentials,
  ]

  metadata {
    name = local.backstage_cluster_namespace
  }
}

# ------------------------------------------------------------------------------
# ENABLE KUBERNETES TO PULL FROM ARTIFACT REGISTRY 
# ------------------------------------------------------------------------------

resource "kubernetes_secret" "artifact_registry_credentials" {
  depends_on = [
    module.backstage_gke,
    kubernetes_namespace.backstage
  ]

  metadata {
    name      = "docker"
    namespace = local.backstage_cluster_namespace
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      "auths" : {
        "https://europe-west3-docker.pkg.dev" : {
          email    = google_service_account.backstage.email
          username = "_json_key"
          password = trimspace(local.service_account_key_as_json)
          auth     = base64encode(join(":", ["_json_key", local.service_account_key_as_json]))
        }
      }
    })
  }
}

# ------------------------------------------------------------------------------
# WORKLOAD IDENTITY CONFIGURATION
# ------------------------------------------------------------------------------

resource "kubernetes_service_account" "backstage" {
  depends_on = [
    kubernetes_namespace.backstage,
  ]

  metadata {
    name      = local.computed_name
    namespace = local.backstage_cluster_namespace

    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.backstage.email
    }
  }

  image_pull_secret {
    name = "docker"
  }
}

resource "google_service_account_iam_member" "backstage_workload_identity" {
  depends_on = [
    kubernetes_namespace.backstage,
    kubernetes_service_account.backstage,
  ]

  service_account_id = google_service_account.backstage.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project}.svc.id.goog[${local.backstage_cluster_namespace}/${local.computed_name}]"
}
