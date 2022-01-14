# ------------------------------------------------------------------------------
# MANAGED ZONE hd.dev.breu.io
# ------------------------------------------------------------------------------

resource "google_dns_managed_zone" "backstage" {
  project     = var.project
  name        = "hd-dev"
  dns_name    = local.dns_zone__name
  description = "HD digital POC domain"
}

resource "google_dns_record_set" "backstage_backend" {
  name         = "${local.dns_zone__record_set__backend__name}.${local.dns_zone__name}"
  managed_zone = google_dns_managed_zone.backstage.name
  project      = var.project
  ttl          = 300
  type         = local.dns_zone__record_set__backend__type
  rrdatas      = local.dns_zone__record_set__backend__data
}

resource "google_dns_record_set" "backstage_firebase_hosting" {
  name         = "${local.dns_zone__record_set__firebase_hosting__name}.${local.dns_zone__name}"
  managed_zone = google_dns_managed_zone.backstage.name
  project      = var.project
  ttl          = 300
  type         = local.dns_zone__record_set__firebase_hosting__type
  rrdatas      = local.dns_zone__record_set__firebase_hosting__data
}
