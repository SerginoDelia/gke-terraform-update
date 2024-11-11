# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service

resource "google_project_service" "google" {
  for_each                   = var.google-service
  service                    = each.value.service
  disable_dependent_services = each.value.enable
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "main" {
  name                            = var.network.name
  routing_mode                    = var.network.routing_mode
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false

  depends_on = [
    google_project_service.google["compute"],
    google_project_service.google["container"]
  ]
}
