# ------------------------------------------------------------------------------
# CREATE DOCKER REGISTRY
# ------------------------------------------------------------------------------

resource "google_artifact_registry_repository" "backstage" {
  provider      = google-beta
  project       = var.project
  location      = var.region
  repository_id = local.cluster__artificat_registry__name
  format        = "DOCKER"
  labels        = var.resource_labels
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
  name                      = local.cluster__name
  region                    = var.region
  network                   = google_compute_network.backstage.name
  subnetwork                = google_compute_subnetwork.backstage_cluster_subnetwork.name
  ip_range_pods             = local.network__cluster_subnetwork__secondary_ip_ranges.pods.range_name
  ip_range_services         = local.network__cluster_subnetwork__secondary_ip_ranges.services.range_name
  create_service_account    = false
  service_account           = local.cluster__workload_identity__google_service_account__email
  default_max_pods_per_node = 64
  enable_private_nodes      = true
  master_ipv4_cidr_block    = "10.100.0.0/28" # 2 ^ 4 ip address
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
      name               = local.cluster__node_pool__backstage__name
      machine_type       = "n2-standard-2"
      min_count          = 1
      max_count          = 32
      local_ssd_count    = 0
      disk_size_gb       = 10
      disk_type          = "pd-ssd"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = local.cluster__workload_identity__google_service_account__email
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
    google_compute_subnetwork.backstage_cluster_subnetwork
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
    name   = local.cluster__namespace__backstage__name
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
    namespace = local.cluster__namespace__backstage__name
    labels    = var.resource_labels
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "https://europe-west3-docker.pkg.dev" = {
          email    = local.cluster__workload_identity__google_service_account__email
          username = "_json_key"
          password = trimspace(local.cluster__workload_identity__google_service_account__key)
          auth     = base64encode(join(":", ["_json_key", local.cluster__workload_identity__google_service_account__key]))
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
    name      = local.cluster__workload_identity__kubernetes_service_account__name
    namespace = local.cluster__namespace__backstage__name

    annotations = {
      "iam.gke.io/gcp-service-account" = local.cluster__workload_identity__google_service_account__email
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

  service_account_id = google_service_account.backstage_cluster_workload_identity.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project}.svc.id.goog[${local.cluster__namespace__backstage__name}/${local.cluster__workload_identity__kubernetes_service_account__name}]"
}

# ------------------------------------------------------------------------------
# DATABASE SECRETS TO BE USED ACCROSS APPLICATIONS
# ------------------------------------------------------------------------------

resource "kubernetes_secret" "backstage_database_credentials" {
  depends_on = [
    module.db,
    kubernetes_namespace.backstage,
  ]

  metadata {
    name      = local.cluster__namespace__backstage__secret__application_credentials__name
    namespace = local.cluster__namespace__backstage__name

    labels = var.resource_labels
  }

  data = {
    db_host = module.db.master_private_ip_address
    db_port = 5432
    db_user = local.database__user
    db_pass = local.database__password
    app_url = local.cluster__namepsace__backstage__component__backend__env__app_url
  }
}

# ------------------------------------------------------------------------------
# RENDERING K8S RESOURCE TEMPLATES
# ------------------------------------------------------------------------------

resource "local_file" "k8s_backend_templates" {
  for_each = fileset("${path.module}/templates", "k8s/backend/*.yaml")

  content = templatefile("${path.module}/templates/${each.key}", {
    backstage__backend__certificate__domain    = local.cluster__namespace__backstage__component__backend__certificate__domain
    backstage__backend__certificate__name      = local.cluster__namepsace__backstage__component__backend__certificate__name
    backstage__backend__container__image       = "${local.cluster__artifact__registry__link}/${local.cluster__namespace__backstage__component__backend__image__name}:${local.cluster__namespace__backstage__component__backend__image__tag}"
    backstage__backend__container__name        = local.cluster__namespace__backstage__component__backend__container__name
    backstage__backend__container__port        = 7007
    backstage__backend__deployment__name       = local.cluster__namespace__backstage__component__backend__deployment__name
    backstage__backend__frontend_config__name  = local.cluster__namespace__backstage__component__backend__frontend__name
    backstage__backend__hpa__name              = local.cluster__namespace__backstage__component__backend__hpa__name
    backstage__backend__ingress__address       = local.cluster__namespace__backstage__component__backend__lb_address__name
    backstage__backend__ingress__name          = local.cluster__namespace__backstage__component__backend__ingress__name
    backstage__backend__labels                 = local.cluster__namespace__backstage__component__backend__labels
    backstage__backend__service__name          = local.cluster__namespace__backstage__component__backend__service__name
    backstage__backend__service__port          = 7007
    backstage__namespace__name                 = local.cluster__namespace__backstage__name
    backstage__secret__application_credentials = local.cluster__namespace__backstage__secret__application_credentials__name
    backstage__service_account__name           = local.cluster__workload_identity__kubernetes_service_account__name
  })

  filename        = "../${each.key}"
  file_permission = "0644"
}
