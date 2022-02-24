output "artifiact_repository_link" {
  description = "Artifact Repository Link"
  value       = local.cluster__artifact__registry__link
}

output "db_instance" {
  description = "Database Instance"
  value       = module.db.instance_name
}

output "db_instance_private_ip_address" {
  description = "Database Instance Private IP Address"
  value       = module.db.private_ip_address
}

output "db_instance_proxy_connection" {
  description = "Database Instance Proxy Connection"
  value       = module.db.instance_connection_name
}

output "dns_managed_zone_name_servers" {
  description = "DNS Managed Zone Name Servers"
  value       = google_dns_managed_zone.backstage.name_servers
}

output "network" {
  description = "VPC Network"
  value       = local.network__name
}

output "network_peering_address_name" {
  description = "Network Peering Address Name"
  value       = google_compute_global_address.backstage_peering_range_address.name
}

output "network_peering_address_ip" {
  description = "Network Peering Address IP"
  value       = google_compute_global_address.backstage_peering_range_address.address
}

output "loadbalancer_address_name" {
  description = "Address Name for Load Balancer"
  value       = local.cluster__namespace__backstage__component__backend__lb_address__name
}
output "cluster_kubeconfig_update_command" {
  description = "Command to update kubeconfig, to use `terraform output -raw cluster_kubeconfig_update_command | sh`"
  value       = "gcloud container clusters get-credentials ${module.backstage_gke.name} --region ${var.region}"
}
