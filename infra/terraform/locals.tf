# ------------------------------------------------------------------------------
# CREATE A RANDOM SUFFIX AND PREPARE RESOURCE NAMES
# ------------------------------------------------------------------------------

resource "random_id" "suffix" {
  byte_length = 4

  keepers = {
    project = var.project,
    region  = var.region,
    prefix  = var.name,
  }
}

resource "random_password" "db_password" {
  length = 16
}

# ------------------------------------------------------------------------------
# RESOLVE THE RESOURCE NAMES TO CREATE
#
# NOTE (ysf): locals are declared in order they are required by the terraform
# NOTE (ysf): however, when not in order, they represent a created resource
# ------------------------------------------------------------------------------

locals {
  dns__zone__name = "hd.dev.breu.io."

  /**
   * Database
   **/

  database__instance_name = "${var.name}-poc-${random_id.suffix.hex}"
  database__database_name = var.db_name
  database__user          = var.db_user
  database__password      = random_password.db_password.result

  /**
   * Cluster
   **/

  cluster__artificat_registry__name = "${var.name}-${random_id.suffix.hex}"
  cluster__artifact__registry__link = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.backstage.name}"

  cluster__name = "${var.name}-cluster-${random_id.suffix.hex}"

  cluster__node_pool__backstage__name = "${var.name}-${random_id.suffix.hex}"

  cluster__namepsace__backstage__component__backend__certificate__name = "backstage-backend-certificate"
  cluster__namespace__backstage__component__backend__container__name   = "backstage-backend"
  cluster__namespace__backstage__component__backend__deployment__name  = "backstage-backend-deployment"
  cluster__namespace__backstage__component__backend__frontend__name    = "backstage-backend-frontend"
  cluster__namespace__backstage__component__backend__hpa__name         = "backstage-backend-hpa"
  cluster__namespace__backstage__component__backend__image__name       = "backstage/backend"
  cluster__namespace__backstage__component__backend__image__tag        = "latest"
  cluster__namespace__backstage__component__backend__ingress__name     = "backstage-backend-ingress"
  cluster__namespace__backstage__component__backend__labels            = merge(var.resource_labels, { component = local.cluster__namespace__backstage__component__backend__name })
  cluster__namespace__backstage__component__backend__lb_address__name  = "${var.name}-backend-loadbalancer-address-${random_id.suffix.hex}"
  cluster__namespace__backstage__component__backend__name              = "backstage-backend"
  cluster__namespace__backstage__component__backend__service__name     = "backstage-backend-service"
  cluster__namespace__backstage__name                                  = var.name
  cluster__namespace__backstage__secret__database_credentials__name    = "${var.name}-database-credentials-${random_id.suffix.hex}"

  cluster__workload_identity__google_service_account__name     = "${var.name}-cluster-${random_id.suffix.hex}"
  cluster__workload_identity__google_service_account__email    = google_service_account.backstage_cluster_workload_identity.email
  cluster__workload_identity__google_service_account__key      = base64decode(google_service_account_key.backstage_cluster_workload_identity_key.private_key)
  cluster__workload_identity__kubernetes_service_account__name = "${var.name}-workload-identity-${random_id.suffix.hex}"

  /**
   * Network
   **/

  network__name = "${var.name}-network-${random_id.suffix.hex}"

  network__cluster_subnetwork__name          = "${var.name}-network-cluster-subnetwork-${random_id.suffix.hex}"
  network__cluster_subnetwork__ip_cidr_range = "10.0.0.0/16"
  network__cluster_subnetwork__secondary_ip_ranges = {
    pods = {
      range_name    = "${var.name}-cluster-subnetwork-range-pods-${random_id.suffix.hex}"
      ip_cidr_range = "10.11.0.0/20"
    }
    services = {
      range_name    = "${var.name}-cluster-subnetwork-range-services-${random_id.suffix.hex}"
      ip_cidr_range = "10.12.0.0/22"
    }
  }

  network__egress__address__name    = "${var.name}-network-egress-address-${random_id.suffix.hex}"
  network__egress__router__name     = "${var.name}-network-egress-router-${random_id.suffix.hex}"
  network__egress__router_nat__name = "${var.name}-network-egress-router-nat-${random_id.suffix.hex}"

  network__peering_range__address__name = "${var.name}-network-peering-address-${random_id.suffix.hex}"




  # iam = {
  #   service_account_key = base64decode(google_service_account_key.backstage.private_key)
  # }

}
