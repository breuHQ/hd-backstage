# ------------------------------------------------------------------------------
# MANAGED ZONE hd.dev.breu.io
# ------------------------------------------------------------------------------

resource "google_dns_managed_zone" "backstage" {
  name        = "hd-dev"
  dns_name    = local.dns_name
  description = "HD digital POC domain"
}
