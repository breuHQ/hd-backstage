# ------------------------------------------------------------------------------
# CREATE DATABASE INSTANCE WITH PRIVATE IP
# ------------------------------------------------------------------------------

module "db" {
  source = "github.com/gruntwork-io/terraform-google-sql.git//modules/cloud-sql?ref=v0.6.0"

  project              = var.project
  region               = var.region
  name                 = local.computed_name
  db_name              = var.db_name
  master_user_name     = var.db_user
  master_user_password = local.db_password
  engine               = var.db_engine
  machine_type         = var.db_machine_type
  disk_autoresize      = true
  deletion_protection  = false
  private_network      = google_compute_network.backstage.self_link
  dependencies         = [google_service_networking_connection.backstage_vpc_connection.network]

  database_flags = [
    {
      name  = "max_connections"
      value = "100"
    }
  ]

  custom_labels = var.resource_labels
}
