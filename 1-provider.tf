# https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "agwe-kubernetes-bucket"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
provider "google" {
  # Configuration options
  project = var.setup.project
  region  = var.setup.region
  # credentials = "key.json"
}

resource "google_compute_disk" "grafana_disk" {
  name = var.grafana_disk.name
  type = var.grafana_disk.type
  zone = var.grafana_disk.zone
  size = var.grafana_disk.size
}
