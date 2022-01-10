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
  source                    = "github.com/terraform-google-modules/terraform-google-kubernetes-engine.git//modules/private-cluster?ref=v18.0.0"
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
  master_ipv4_cidr_block    = "10.1.1.0/28" # 2 ^ 4 ip address
  remove_default_node_pool  = true

  cluster_autoscaling = {
    enabled             = true
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
    min_cpu_cores       = 1
    max_cpu_cores       = 8
    min_memory_gb       = 1
    max_memory_gb       = 32
    gpu_resources       = []
  }

  cluster_resource_labels = var.resource_labels

  node_pools = [
    {
      name               = "${local.computed_name}-node-pool"
      machine_type       = "n2-standard-2"
      min_count          = 1
      max_count          = 32
      local_ssd_count    = 0
      disk_size_gb       = 10
      disk_type          = "pd-ssd"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = google_service_account.backstage.email
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
    all = var.resource_labels
  }

  depends_on = [
    google_compute_subnetwork.backstage
  ]
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
    name   = local.backstage_cluster_namespace
    labels = var.resource_labels
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
    labels    = var.resource_labels
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
    name      = "backstage"
    namespace = local.backstage_cluster_namespace

    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.backstage.email
    }

    labels = var.resource_labels
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

# ------------------------------------------------------------------------------
# DATABASE SECRETS TO BE USED ACCROSS APPLICATIONS
# ------------------------------------------------------------------------------

resource "kubernetes_secret" "backstage_db_credentials" {
  depends_on = [
    module.db,
    kubernetes_namespace.backstage,
  ]

  metadata {
    name      = "backstage-db-credentials"
    namespace = local.backstage_cluster_namespace

    labels = var.resource_labels
  }

  data = {
    db_host = module.db.master_private_ip_address
    db_port = 5432
    db_user = var.db_user
    db_pass = local.db_password
  }
}

# ------------------------------------------------------------------------------
# RENDERING K8S RESOURCE TEMPLATES
# ------------------------------------------------------------------------------

# resource "template_dir" "k8s_backend_templates" {
#   source_dir      = "${path.module}/templates/k8s/backend"
#   destination_dir = "rendered/templates"

#   vars = {
#     metadata_name      = "backend"
#     metadata_namespace = local.backstage_cluster_namespace
#     # resource_labels    = trimspace(indent(4, yamlencode(var.resource_labels)))
#     resource_labels    = ["a", "b", "c"]
#     repository_link    = local.respository_link
#     image_name         = "backstage/backend"
#     image_tag          = "latest"
#     certificate_domain = trimsuffix(google_dns_record_set.backstage_backend.name, ".")
#   }
# }

resource "local_file" "k8s_backend_templates" {
  for_each = fileset(
    "${path.module}/templates/k8s/backend",
    "*.yaml"
  )

  content = templatefile("${path.module}/templates/k8s/backend/${each.key}", {
    # resource_labels    = trimspace(indent(4, yamlencode(var.resource_labels)))
    certificate_domain = trimsuffix(google_dns_record_set.backstage_backend.name, ".")
    image_name         = "backstage/backend"
    image_tag          = "latest"
    metadata_name      = "backend"
    metadata_namespace = local.backstage_cluster_namespace
    repository_link    = local.respository_link
    resource_labels = merge(var.resource_labels, {
      component = "backend"
    })
  })

  filename = "./rendered/${each.key}"
}
