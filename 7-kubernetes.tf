# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster
resource "google_container_cluster" "clusters" {
  for_each                 = var.clusters
  name                     = each.key
  location                 = each.value.location
  remove_default_node_pool = true
  initial_node_count       = each.value.initial_node_count
  network                  = google_compute_network.main.self_link
  subnetwork               = google_compute_subnetwork.subnet["private"].self_link
  logging_service          = each.value.logging
  monitoring_service       = each.value.monitoring
  networking_mode          = each.value.networking_mode

  # Optional, if you want multi-zonal cluster
  node_locations = [each.value.node_locations]

  addons_config {
    http_load_balancing {
      disabled = true
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = each.value.channel
  }

  workload_identity_config {
    workload_pool = each.value.workload_pool
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = each.value.cluster_secondary_range_name
    services_secondary_range_name = each.value.services_secondary_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = each.value.master_ipv4_cidr
  }

  #   Jenkins use case
  #   master_authorized_networks_config {
  #     cidr_blocks {
  #       cidr_block   = "10.0.0.0/18"
  #       display_name = "private-subnet-w-jenkins"
  #     }
  #   }
}
