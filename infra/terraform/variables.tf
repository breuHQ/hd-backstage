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
  default     = "backstage"
}

variable "db_name" {
  description = "The name of the database to create."
  default     = "backstage"
}

variable "db_engine" {
  description = "The version of the database to use."
  default     = "POSTGRES_14"
}

variable "db_machine_type" {
  description = "The machine type to use, see https://cloud.google.com/sql/pricing for more details"
  type        = string
  default     = "db-f1-micro"
}
