# ------------------------------------------------------------------------------
# CREATE SERVICE ACCOUNT WITH ROLES AND SCOPES FOR WORKLOAD IDENTITY
# ------------------------------------------------------------------------------

resource "google_service_account" "backstage" {
  account_id   = local.computed_name
  display_name = "Backstage Service Account"
  project      = var.project
}

resource "google_service_account_key" "backstage" {
  service_account_id = local.computed_name

  depends_on = [
    google_service_account.backstage
  ]
}

resource "google_project_iam_member" "service_account_roles" {
  for_each = toset(var.service_account_roles)

  project = var.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.backstage.email}"
}
