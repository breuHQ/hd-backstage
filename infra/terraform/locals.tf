# ------------------------------------------------------------------------------
# CREATE A RANDOM SUFFIX AND PREPARE RESOURCE NAMES
# ------------------------------------------------------------------------------

resource "random_id" "suffix" {
  byte_length = 4

  keepers = {
    project = var.project,
    region  = var.region,
    prefix  = var.name_prefix
  }
}

resource "random_password" "db_password" {
  length = 16
}

locals {
  # If name_override is specified, use that - otherwise use the name_prefix with a random string
  computed_name                            = "${var.name_prefix}-${random_id.suffix.hex}"
  service_account_key_as_json              = base64decode(google_service_account_key.backstage.private_key)
  db_password                              = random_password.db_password.result
  backstage_cluster_pods_ip_range_name     = "${local.computed_name}-backstage-gke-pods"
  backstage_cluster_services_ip_range_name = "${local.computed_name}-backstage-gke-services"
  backstage_cluster_namespace              = var.name_prefix
}
