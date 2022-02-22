## Requirements

| Name                                                                           | Version           |
| ------------------------------------------------------------------------------ | ----------------- |
| <a name="requirement_google"></a> [google](#requirement_google)                | >= 4.0.0, < 5.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement_google-beta) | >= 4.0.0, < 5.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement_kubernetes)    | >= 2.8.0          |
| <a name="requirement_local"></a> [local](#requirement_local)                   | >= 2.1.0          |
| <a name="requirement_null"></a> [null](#requirement_null)                      | >= 3.1.0          |
| <a name="requirement_random"></a> [random](#requirement_random)                | >= 3.1.0          |

## Providers

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="provider_google"></a> [google](#provider_google)                | 4.10.0  |
| <a name="provider_google-beta"></a> [google-beta](#provider_google-beta) | 4.10.0  |
| <a name="provider_kubernetes"></a> [kubernetes](#provider_kubernetes)    | 2.8.0   |
| <a name="provider_local"></a> [local](#provider_local)                   | 2.1.0   |
| <a name="provider_null"></a> [null](#provider_null)                      | 3.1.0   |
| <a name="provider_random"></a> [random](#provider_random)                | 3.1.0   |

## Modules

| Name                                                                       | Source                                                                                              | Version |
| -------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- | ------- |
| <a name="module_backstage_gke"></a> [backstage_gke](#module_backstage_gke) | github.com/terraform-google-modules/terraform-google-kubernetes-engine.git//modules/private-cluster | v19.0.0 |
| <a name="module_db"></a> [db](#module_db)                                  | GoogleCloudPlatform/sql-db/google//modules/postgresql                                               | 9.0.0   |

## Inputs

| Name                                                                                             | Description                                                                          | Type           | Default                                                                                                                                                                                                                                                                 | Required |
| ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------ | -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_db_engine"></a> [db_engine](#input_db_engine)                                     | The version of the database to use.                                                  | `string`       | `"POSTGRES_14"`                                                                                                                                                                                                                                                         |    no    |
| <a name="input_db_flags"></a> [db_flags](#input_db_flags)                                        | The database flags, see <https://cloud.google.com/sql/docs/postgres/flags>           | `list`         | <pre>[<br> {<br> "name": "max_connections",<br> "value": "100"<br> }<br>]</pre>                                                                                                                                                                                         |    no    |
| <a name="input_db_name"></a> [db_name](#input_db_name)                                           | The name of the database to create.                                                  | `string`       | `"backstage"`                                                                                                                                                                                                                                                           |    no    |
| <a name="input_db_tier"></a> [db_tier](#input_db_tier)                                           | The machine type to use, see <https://cloud.google.com/sql/pricing> for more details | `string`       | `"db-f1-micro"`                                                                                                                                                                                                                                                         |    no    |
| <a name="input_db_user"></a> [db_user](#input_db_user)                                           | The database user                                                                    | `string`       | `"backstage"`                                                                                                                                                                                                                                                           |    no    |
| <a name="input_dns_zone"></a> [dns_zone](#input_dns_zone)                                        | The DNS zone to use for the Cloud DNS                                                | `string`       | `"hd.dev.breu.io."`                                                                                                                                                                                                                                                     |    no    |
| <a name="input_name"></a> [name](#input_name)                                                    | The prefix of items in your Google Cloud Platform project.                           | `string`       | `"backstage"`                                                                                                                                                                                                                                                           |    no    |
| <a name="input_project"></a> [project](#input_project)                                           | The ID of your Google Cloud Platform project.                                        | `string`       | `"hd-backstage-poc-28107"`                                                                                                                                                                                                                                              |    no    |
| <a name="input_region"></a> [region](#input_region)                                              | The region of your Google Cloud Platform project.                                    | `string`       | `"europe-west3"`                                                                                                                                                                                                                                                        |    no    |
| <a name="input_resource_labels"></a> [resource_labels](#input_resource_labels)                   | n/a                                                                                  | `map`          | <pre>{<br> "application": "backstage",<br> "environment": "poc",<br> "team": "breu"<br>}</pre>                                                                                                                                                                          |    no    |
| <a name="input_service_account_roles"></a> [service_account_roles](#input_service_account_roles) | The service account roles for workload identity                                      | `list(string)` | <pre>[<br> "roles/artifactregistry.reader",<br> "roles/cloudsql.client",<br> "roles/logging.logWriter",<br> "roles/monitoring.metricWriter",<br> "roles/stackdriver.resourceMetadata.writer",<br> "roles/storage.objectViewer",<br> "roles/cloudtrace.agent"<br>]</pre> |    no    |

## Outputs

| Name                                                                                                                                   | Description                                                                                   |
| -------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | --- |
| <a name="output_artifiact_repository_link"></a> [artifiact_repository_link](#output_artifiact_repository_link)                         | Artifact Repository Link                                                                      |
| <a name="output_cluster_kubeconfig_update_command"></a> [cluster_kubeconfig_update_command](#output_cluster_kubeconfig_update_command) | Command to update kubeconfig, to use `terraform output -raw cluster_kubeconfig_update_command | sh` |
| <a name="output_db_instance"></a> [db_instance](#output_db_instance)                                                                   | Database Instance                                                                             |
| <a name="output_db_instance_private_ip_address"></a> [db_instance_private_ip_address](#output_db_instance_private_ip_address)          | Database Instance Private IP Address                                                          |
| <a name="output_db_instance_proxy_connection"></a> [db_instance_proxy_connection](#output_db_instance_proxy_connection)                | Database Instance Proxy Connection                                                            |
| <a name="output_dns_managed_zone_name_servers"></a> [dns_managed_zone_name_servers](#output_dns_managed_zone_name_servers)             | DNS Managed Zone Name Servers                                                                 |
| <a name="output_network_peering_address"></a> [network_peering_address](#output_network_peering_address)                               | Network Peering Address                                                                       |
