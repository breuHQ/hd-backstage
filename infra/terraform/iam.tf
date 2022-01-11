# ------------------------------------------------------------------------------
# CREATE SERVICE ACCOUNT WITH ROLES AND SCOPES FOR WORKLOAD IDENTITY
# ------------------------------------------------------------------------------

resource "google_service_account" "backstage_cluster_workload_identity" {
  account_id   = local.cluster__workload_identity__google_service_account__name
  display_name = "Backstage Service Account"
  project      = var.project
}

resource "google_service_account_key" "backstage_cluster_workload_identity_key" {
  service_account_id = local.cluster__workload_identity__google_service_account__name

  depends_on = [
    google_service_account.backstage_cluster_workload_identity
  ]
}

resource "google_project_iam_member" "service_account_roles" {
  for_each = toset(var.service_account_roles)

  project = var.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.backstage_cluster_workload_identity.email}"
}
