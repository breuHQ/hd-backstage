# ------------------------------------------------------------------------------
# CREATE DATABASE INSTANCE WITH PRIVATE IP
# ------------------------------------------------------------------------------

# module "db" {
#   source = "github.com/gruntwork-io/terraform-google-sql.git//modules/cloud-sql?ref=v0.6.0"

#   project              = var.project
#   region               = var.region
#   name                 = local.database__instance_name
#   db_name              = local.database__database_name
#   master_user_name     = local.database__user
#   master_user_password = local.database__password
#   engine               = var.db_engine
#   machine_type         = var.db_machine_type
#   disk_autoresize      = true
#   deletion_protection  = false
#   private_network      = google_compute_network.backstage.self_link
#   dependencies         = [google_service_networking_connection.backstage_peering_connection.network]

#   database_flags = [
#     {
#       name  = "max_connections"
#       value = "100"
#     }
#   ]

#   custom_labels = var.resource_labels
# }

module "db" {
  source              = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version             = "9.0.0"
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
    ipv4_enabled        = false
  }

  module_depends_on = [google_service_networking_connection.backstage_peering_connection.network]
}
