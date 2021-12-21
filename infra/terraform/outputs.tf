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
