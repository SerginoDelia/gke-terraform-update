# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "kubernetes" {
  account_id = var.setup.account_id
}

# import the existing kubernetes service account
# terraform import google_service_account.kubernetes projects/agwe-3/serviceAccounts/kubernetes@agwe-3.iam.gserviceaccount.com

# pull the existing kubernetes service account
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
# data "google_service_account" "kubernetes" {
#   account_id = "kubernetes"
#   project    = "agwe-3"
# }


# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool
resource "google_container_node_pool" "nodes" {
  for_each   = var.node-pools
  name       = each.key
  cluster    = google_container_cluster.clusters["primary"].id
  node_count = each.key == "general" ? tonumber(each.value.node_count) : null

  management {
    auto_repair  = each.value.auto_repair
    auto_upgrade = each.value.auto_upgrade
  }

  #  autoscaling {
  #     min_node_count = 0
  #     max_node_count = 10
  #   }
  autoscaling {
    min_node_count = each.key == "spot" ? tonumber(each.value.min_node_count) : 0
    max_node_count = each.key == "spot" ? tonumber(each.value.max_node_count) : 10
  }

  node_config {
    preemptible  = false
    machine_type = each.value.machine_type

    labels = {
      role = each.key == "general" ? each.value.role : null
      team = each.key == "spot" ? each.value.team : null
    }
    # dynamic block
    # https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks
    dynamic "taint" {
      for_each = each.key == "spot" ? [each.value] : []
      content {
        key    = taint.value.taint_key
        value  = taint.value.taint_value
        effect = taint.value.taint_effect
      }
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes    = [each.value.auth_scopes]
  }
}

