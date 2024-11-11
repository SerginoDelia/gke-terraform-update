# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "service-a" {
  account_id = var.service-account.account_id
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
resource "google_project_iam_member" "service-a" {
  project = var.setup.project
  role    = var.project-iam-member.role
  member  = "serviceAccount:${google_service_account.service-a.email}"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam
resource "google_service_account_iam_member" "service-a" {
  service_account_id = google_service_account.service-a.id
  role               = var.account-iam-member.role
  member             = var.account-iam-member.member
}

# Import service account resource, because its aleady created
# terraform import google_service_account.service-a projects/agwe-3/serviceAccounts/service-a@agwe-3.iam.gserviceaccount.com
