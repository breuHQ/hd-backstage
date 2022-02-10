output "artifiact_repository_link" {
  value = local.cluster__artifact__registry__link
}

output "db_instance" {
  value = module.db.instance_name
}

output "db_instance_ip_address" {
  value = module.db.instance_ip_address[0].ip_address
}

output "db_instance_private_ip_address" {
  value = module.db.private_ip_address
}

output "db_instance_self_link" {
  value = module.db.instance_self_link
}

output "db_instance_proxy_connection" {
  value = module.db.instance_connection_name
}

output "dns_managed_zone_name_servers" {
  value = google_dns_managed_zone.backstage.name_servers
}

output "network_peering_address" {
  value = google_compute_global_address.backstage_peering_range_address.address
}
output "cmd_kubeconfig_update" {
  value = "gcloud container clusters get-credentials ${module.backstage_gke.name} --region ${var.region}"
}
