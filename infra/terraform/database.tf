# ------------------------------------------------------------------------------
# CREATE DATABASE INSTANCE WITH PRIVATE IP
# ------------------------------------------------------------------------------

module "db" {
  source              = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version             = "10.0.0"
  project_id          = var.project
  region              = var.region
  name                = local.database__instance_name
  db_name             = local.database__database_name
  user_name           = local.database__user
  user_password       = local.database__password
  database_version    = var.db_engine
  tier                = var.db_tier
  disk_autoresize     = true
  deletion_protection = false
  enable_default_db   = true
  enable_default_user = true
  database_flags      = var.db_flags
  user_labels         = var.resource_labels
  zone                = "${var.region}-c"

  ip_configuration = {
    authorized_networks = []
    require_ssl         = false
    private_network     = google_compute_network.backstage.self_link
    allocated_ip_range  = null
    ipv4_enabled        = false
  }

  module_depends_on = [google_service_networking_connection.backstage_peering_connection.network]
}
