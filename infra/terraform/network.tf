# ------------------------------------------------------------------------------
# CREATE COMPUTE NETWORKS
# ------------------------------------------------------------------------------

# Simple network, auto-creates subnetworks
resource "google_compute_network" "backstage" {
  name                    = local.network__name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "backstage_cluster_subnetwork" {
  name                     = local.network__cluster_subnetwork__name
  region                   = var.region
  ip_cidr_range            = local.network__cluster_subnetwork__ip_cidr_range
  network                  = google_compute_network.backstage.self_link
  private_ip_google_access = true
  secondary_ip_range       = [for _, ip_range in local.network__cluster_subnetwork__secondary_ip_ranges : ip_range]
}

# ------------------------------------------------------------------------------
# CREATE IP RANGE FOR PEERING
# ------------------------------------------------------------------------------
resource "google_compute_global_address" "backstage_peering_range_address" {
  provider      = google-beta
  name          = local.network__peering_range__address__name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.backstage.self_link
  labels        = var.resource_labels
}

# ------------------------------------------------------------------------------
# CREATE BACKSTAGE CONNECTION FOR BACKSTAGE IP PEERING RANGE
# ------------------------------------------------------------------------------
resource "google_service_networking_connection" "backstage_peering_connection" {
  network                 = google_compute_network.backstage.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.backstage_peering_range_address.name]
}

# ------------------------------------------------------------------------------
# EGRESS ONLY ACCESS FOR ALL RESOURCES IN BACKSTAGE NETWORK VIA CLOUD NAT
# ------------------------------------------------------------------------------

resource "google_compute_router" "backstage_network_egress_router" {
  name    = local.network__egress__router__name
  project = var.project
  region  = var.region
  network = google_compute_network.backstage.name
}

resource "google_compute_address" "backstage_network_egress_address" {
  provider = google-beta
  name     = local.network__egress__address__name
  project  = var.project
  region   = var.region
  labels   = var.resource_labels
}

resource "google_compute_router_nat" "backstage_network_egress_router_nat" {
  name                               = local.network__egress__router_nat__name
  router                             = google_compute_router.backstage_network_egress_router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  nat_ips = [
    google_compute_address.backstage_network_egress_address.self_link
  ]

  subnetwork {
    name                     = google_compute_subnetwork.backstage_cluster_subnetwork.self_link
    source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]
    secondary_ip_range_names = [for _, ip_range in local.network__cluster_subnetwork__secondary_ip_ranges : ip_range.range_name]
  }

  log_config {
    enable = true
    filter = "ALL"
  }
}

# ------------------------------------------------------------------------------
# BACKSTAGE IP FOR BACKEND TO BE ASSIGNED TO LOAD BALANCER
# ------------------------------------------------------------------------------

resource "google_compute_global_address" "backend_cluster_backend_loadbalancer_address" {
  provider = google-beta
  project  = var.project
  name     = local.cluster__namespace__backstage__component__backend__lb_address__name
  labels   = var.resource_labels
}
