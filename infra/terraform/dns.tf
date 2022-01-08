# ------------------------------------------------------------------------------
# MANAGED ZONE hd.dev.breu.io
# ------------------------------------------------------------------------------

resource "google_dns_managed_zone" "backstage" {
  project     = var.project
  name        = "hd-dev"
  dns_name    = local.dns_name
  description = "HD digital POC domain"
}

resource "google_dns_record_set" "backstage_backend" {
  name         = "backend.${local.dns_name}"
  managed_zone = google_dns_managed_zone.backstage.name
  project      = var.project
  ttl          = 300
  type         = "A"
  rrdatas = [
    google_compute_global_address.backstage_backend.address,
  ]
}
