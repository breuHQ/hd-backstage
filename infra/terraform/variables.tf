variable "project" {
  description = "The ID of your Google Cloud Platform project."
  default     = "hd-backstage-poc-28107"
}

variable "region" {
  description = "The region of your Google Cloud Platform project."
  default     = "europe-west3"
}

variable "name" {
  description = "The prefix of items in your Google Cloud Platform project."
  default     = "backstage"
}

variable "db_name" {
  description = "The name of the database to create."
  default     = "backstage"
}

variable "db_user" {
  description = "The database user"
  default     = "backstage"
}

variable "db_engine" {
  description = "The version of the database to use."
  default     = "POSTGRES_14"
}

variable "db_flags" {
  description = "The database flags, see https://cloud.google.com/sql/docs/postgres/flags"
  default = [
    {
      name  = "max_connections"
      value = "100"
    }
  ]
}

variable "db_tier" {
  description = "The machine type to use, see https://cloud.google.com/sql/pricing for more details"
  type        = string
  default     = "db-f1-micro"
}

variable "dns_zone" {
  description = "The DNS zone to use for the Cloud DNS"
  default     = "hd.dev.breu.io."
}

variable "service_account_roles" {
  description = "The service account roles for workload identity"
  type        = list(string)
  default = [
    "roles/artifactregistry.reader",
    "roles/cloudsql.client",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/stackdriver.resourceMetadata.writer",
    # "roles/storage.objectViewer",
    "roles/storage.admin",
    "roles/cloudtrace.agent",
  ]
}

variable "resource_labels" {
  # type = map(any)
  default = {
    application = "backstage"
    environment = "poc"
    team        = "breu"
  }
}

variable "secret_gitlab_token" {
  type = string
}

variable "secret_gitlab_discovery_url" {
  type = string
}

variable "secret_onelogin_client_id" {
  type = string
}

variable "secret_onelogin_client_secret" {
  type = string
}

variable "secret_onelogin_issuer" {
  type = string
}
