# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
resource "google_compute_subnetwork" "subnet" {
  for_each                 = var.subnet
  name                     = each.key
  ip_cidr_range            = each.value.cidr
  region                   = each.value.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = each.value.pod_range_name
    ip_cidr_range = each.value.pod_cidr
  }
  secondary_ip_range {
    range_name    = each.value.service_range_name
    ip_cidr_range = each.value.service_cidr
  }
}
