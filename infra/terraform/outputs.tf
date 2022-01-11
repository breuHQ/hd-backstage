output "artifiact_repository_link" {
  value = local.cluster__artifact__registry__link
}

output "db_instance" {
  value = module.db.master_instance_name
}

output "database_instance_private_ip" {
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

output "network_peering_address" {
  value = google_compute_global_address.backstage_peering_range_address.address
}

# output "suffix" {
#   value = random_id.suffix.hex
# }
