# ------------------------------------------------------------------------------
# CREATE A RANDOM SUFFIX AND PREPARE RESOURCE NAMES
# ------------------------------------------------------------------------------

resource "random_id" "name" {
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
  computed_name        = "${var.name_prefix}-${random_id.name.hex}"
  master_user_password = random_password.db_password.result
}
