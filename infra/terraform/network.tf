# ------------------------------------------------------------------------------
# CREATE COMPUTE NETWORKS
# ------------------------------------------------------------------------------

# Simple network, auto-creates subnetworks
resource "google_compute_network" "backstage" {
  provider                = google-beta
  name                    = "${local.computed_name}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "backstage" {
  provider                 = google-beta
  name                     = "${local.computed_name}-subnetwork"
  region                   = var.region
  ip_cidr_range            = "10.0.0.0/16" # 256 x 256 possible ip address
  network                  = google_compute_network.backstage.self_link
  private_ip_google_access = true

  secondary_ip_range = [
    {
      range_name    = local.backstage_cluster_pods_ip_range_name
      ip_cidr_range = "10.2.0.0/16" # 256 x 256 possible ip address
    },
    {
      range_name    = local.backstage_cluster_services_ip_range_name
      ip_cidr_range = "10.3.0.0/16" # 256 x 256 possible ip address
    }
  ]
}

# ------------------------------------------------------------------------------
# CREATE IP FOR VPC PEERING
# ------------------------------------------------------------------------------
resource "google_compute_global_address" "peering_ip_address" {
  provider      = google-beta
  name          = "${local.computed_name}-peering-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.backstage.self_link

  labels = {
    application = "backstage"
    environment = "poc"
  }
}

# ------------------------------------------------------------------------------
# BIND PEERING IP TO NETWORK
# ------------------------------------------------------------------------------
resource "google_service_networking_connection" "backstage_vpc_connection" {
  provider                = google-beta
  network                 = google_compute_network.backstage.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.peering_ip_address.name]
}
