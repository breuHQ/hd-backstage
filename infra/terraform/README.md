## Requirements

| Name                                                                           | Version           |
| ------------------------------------------------------------------------------ | ----------------- |
| <a name="requirement_google"></a> [google](#requirement_google)                | >= 4.0.0, < 5.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement_google-beta) | >= 4.0.0, < 5.0.0 |

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

## Resources

| Name                                                                                                                                                                                                        | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [google-beta_google_artifact_registry_repository.backstage](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_artifact_registry_repository)                        | resource    |
| [google-beta_google_compute_address.backstage_network_egress_address](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_address)                           | resource    |
| [google-beta_google_compute_global_address.backend_cluster_backend_loadbalancer_address](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_global_address) | resource    |
| [google-beta_google_compute_global_address.backstage_peering_range_address](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_global_address)              | resource    |
| [google_compute_network.backstage](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network)                                                                          | resource    |
| [google_compute_router.backstage_network_egress_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router)                                                      | resource    |
| [google_compute_router_nat.backstage_network_egress_router_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat)                                          | resource    |
| [google_compute_subnetwork.backstage_cluster_subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork)                                                 | resource    |
| [google_dns_managed_zone.backstage](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone)                                                                        | resource    |
| [google_dns_record_set.backstage_backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set)                                                                    | resource    |
| [google_dns_record_set.backstage_firebase_hosting](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set)                                                           | resource    |
| [google_project_iam_member.service_account_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member)                                                        | resource    |
| [google_service_account.backstage_cluster_workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account)                                                | resource    |
| [google_service_account_iam_member.backstage_workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member)                                  | resource    |
| [google_service_account_key.backstage_cluster_workload_identity_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key)                                    | resource    |
| [google_service_networking_connection.backstage_peering_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection)                           | resource    |
| [kubernetes_namespace.backstage](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace)                                                                              | resource    |
| [kubernetes_secret.artifact_registry_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret)                                                                | resource    |
| [kubernetes_secret.backstage_database_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret)                                                               | resource    |
| [kubernetes_service_account.backstage](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account)                                                                  | resource    |
| [local_file.k8s_backend_templates](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file)                                                                                      | resource    |
| [null_resource.backstage_cluster_credentials](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource)                                                                        | resource    |
| [random_id.db](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)                                                                                                           | resource    |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)                                                                                                       | resource    |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)                                                                                      | resource    |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config)                                                                             | data source |

## Inputs

| Name                                                                                             | Description                                                                        | Type           | Default                                                                                                                                                                                                                                                                 | Required |
| ------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_db_engine"></a> [db_engine](#input_db_engine)                                     | The version of the database to use.                                                | `string`       | `"POSTGRES_14"`                                                                                                                                                                                                                                                         |    no    |
| <a name="input_db_flags"></a> [db_flags](#input_db_flags)                                        | The database flags, see https://cloud.google.com/sql/docs/postgres/flags           | `list`         | <pre>[<br> {<br> "name": "max_connections",<br> "value": "100"<br> }<br>]</pre>                                                                                                                                                                                         |    no    |
| <a name="input_db_name"></a> [db_name](#input_db_name)                                           | The name of the database to create.                                                | `string`       | `"backstage"`                                                                                                                                                                                                                                                           |    no    |
| <a name="input_db_tier"></a> [db_tier](#input_db_tier)                                           | The machine type to use, see https://cloud.google.com/sql/pricing for more details | `string`       | `"db-f1-micro"`                                                                                                                                                                                                                                                         |    no    |
| <a name="input_db_user"></a> [db_user](#input_db_user)                                           | The database user                                                                  | `string`       | `"backstage"`                                                                                                                                                                                                                                                           |    no    |
| <a name="input_dns_zone"></a> [dns_zone](#input_dns_zone)                                        | The DNS zone to use for the Cloud DNS                                              | `string`       | `"hd.dev.breu.io."`                                                                                                                                                                                                                                                     |    no    |
| <a name="input_name"></a> [name](#input_name)                                                    | The prefix of items in your Google Cloud Platform project.                         | `string`       | `"backstage"`                                                                                                                                                                                                                                                           |    no    |
| <a name="input_project"></a> [project](#input_project)                                           | The ID of your Google Cloud Platform project.                                      | `string`       | `"hd-backstage-poc-28107"`                                                                                                                                                                                                                                              |    no    |
| <a name="input_region"></a> [region](#input_region)                                              | The region of your Google Cloud Platform project.                                  | `string`       | `"europe-west3"`                                                                                                                                                                                                                                                        |    no    |
| <a name="input_resource_labels"></a> [resource_labels](#input_resource_labels)                   | n/a                                                                                | `map`          | <pre>{<br> "application": "backstage",<br> "environment": "poc",<br> "team": "breu"<br>}</pre>                                                                                                                                                                          |    no    |
| <a name="input_service_account_roles"></a> [service_account_roles](#input_service_account_roles) | The service account roles for workload identity                                    | `list(string)` | <pre>[<br> "roles/artifactregistry.reader",<br> "roles/cloudsql.client",<br> "roles/logging.logWriter",<br> "roles/monitoring.metricWriter",<br> "roles/stackdriver.resourceMetadata.writer",<br> "roles/storage.objectViewer",<br> "roles/cloudtrace.agent"<br>]</pre> |    no    |

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
