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
# resource "google_container_node_pool" "general" {
#   name       = "general"
#   cluster    = google_container_cluster.clusters["primary"].id
#   node_count = 1

#   management {
#     auto_repair  = true
#     auto_upgrade = true
#   }

#   node_config {
#     preemptible  = false
#     machine_type = "n2-standard-8"

#     labels = {
#       role = "general"
#     }

#     service_account = google_service_account.kubernetes.email
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }
# }

# resource "google_container_node_pool" "spot" {
#   name    = "spot"
#   cluster = google_container_cluster.primary.id

#   management {
#     auto_repair  = true
#     auto_upgrade = true
#   }

#   autoscaling {
#     min_node_count = 0
#     max_node_count = 10
#   }

#   node_config {
#     preemptible  = false
#     machine_type = "n2-standard-8"

#     labels = {
#       team = "devops"
#     }

#     taint {
#       key    = "instance_type"
#       value  = "spot"
#       effect = "NO_SCHEDULE"
#     }

#     service_account = google_service_account.kubernetes.email
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }
# }

# connect Kubernetes to local machine
# resource "null_resource" "get_credentials" {
#   provisioner "local-exec" {
#     command = "gcloud container clusters get-credentials primary --zone ${var.zone} --project ${var.project}"
#   }
#   depends_on = [google_container_cluster.primary]
# }

# enable api-gateway
# Enable-Gateway-API:
# gcloud container clusters update atreides-war-fleet \
#     --region europe-west10 \
#     --gateway-api=standard


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

