variable "project" {
  description = "The ID of your Google Cloud Platform project."
  default     = "hd-backstage-poc-28107"
}

variable "region" {
  description = "The region of your Google Cloud Platform project."
  default     = "europe-west3"
}

variable "name_prefix" {
  description = "The prefix of items in your Google Cloud Platform project."
  default     = "hd-backstage-poc"
}

variable "name_override" {
  description = "The override of items in your Google Cloud Platform project."
  default     = ""
}

variable "database_engine" {
  description = "The version of the database to use."
  default     = "POSTGRES_14"
}

variable "machine_type" {
  description = "The machine type to use, see https://cloud.google.com/sql/pricing for more details"
  type        = string
  default     = "db-f1-micro"
}
