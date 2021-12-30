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
  ip_cidr_range            = "10.0.0.0/16" # 2^16 possible ip address
  network                  = google_compute_network.backstage.self_link
  private_ip_google_access = true

  secondary_ip_range = [
    {
      range_name    = "${local.computed_name}-gke-pods"
      ip_cidr_range = "10.1.2.0/24"
    },
    {
      range_name    = "${local.computed_name}-gke-services"
      ip_cidr_range = "10.1.3.0/24"
    }

  ]
}

# Reserve global internal address range for the peering
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

# Establish VPC network peering connection using the reserved address range
resource "google_service_networking_connection" "backstage_vpc_connection" {
  provider                = google-beta
  network                 = google_compute_network.backstage.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.peering_ip_address.name]
}
