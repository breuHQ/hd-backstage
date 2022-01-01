output "artifiact_repository_link" {
  value = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.backstage.name}"
}

output "db_instance" {
  value = module.db.master_instance_name
}

output "db_instance_private_ip" {
  value = module.db.master_private_ip_address
}

output "db_instance_link" {
  value = module.db.master_instance
}

output "db_instance_proxy_connection" {
  value = module.db.master_proxy_connection
}

output "dns_managed_zone_name_servers" {
  value = google_dns_managed_zone.backstage.name_servers
}

output "suffix" {
  value = random_id.suffix.hex
}
