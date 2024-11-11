variable "setup" {
  type = map(string)
  default = {
    project    = "agwe-3"
    region     = "us-central1"
    account_id = "kubernetes"
  }
}

variable "grafana_disk" {
  type = map(string)
  default = {
    name = "grafana-disk"
    type = "pd-standard"
    zone = "us-central1-a"
    size = "10"
  }
}

variable "google-service" {
  type = map(map(string))
  default = {
    compute = {
      service = "compute.googleapis.com"
      enable  = true
    }
    container = {
      service = "container.googleapis.com"
      enable  = true
    }
  }
}

variable "network" {
  type = map(string)
  default = {
    name         = "main"
    routing_mode = "REGIONAL"
  }
}

variable "subnet" {
  type = map(map(string))
  default = {
    private = {
      cidr               = "10.0.0.0/18"
      region             = "us-central1"
      pod_range_name     = "k8s-pod-range"
      pod_cidr           = "10.48.0.0/14"
      service_range_name = "k8s-service-range"
      service_cidr       = "10.52.0.0/20"
    }
  }
}

variable "allow-ssh" {
  type = map(string)
  default = {
    name          = "allow-ssh"
    protocol      = "tcp"
    ports         = "22"
    source_ranges = "0.0.0.0/0"
  }
}

variable "clusters" {
  type = map(map(string))
  default = {
    primary = {
      location                      = "us-central1-a"
      initial_node_count            = 1
      logging                       = "logging.googleapis.com/kubernetes"
      monitoring                    = "monitoring.googleapis.com/kubernetes"
      networking_mode               = "VPC_NATIVE"
      node_locations                = "us-central1-b"
      channel                       = "REGULAR"
      workload_pool                 = "agwe-3.svc.id.goog"
      cluster_secondary_range_name  = "k8s-pod-range"
      services_secondary_range_name = "k8s-service-range"
      master_ipv4_cidr              = "172.16.0.0/28"
    }
  }
}

variable "node-pools" {
  type = map(map(string))
  default = {
    general = {
      node_count     = 1
      auto_repair    = true
      auto_upgrade   = true
      min_node_count = ""
      max_node_count = ""
      preemptible    = false
      machine_type   = "n2-standard-8"
      role           = "general"
      auth_scopes    = "https://www.googleapis.com/auth/cloud-platform"
    }
    spot = {
      node_count     = ""
      auto_repair    = true
      auto_upgrade   = true
      min_node_count = "0"
      max_node_count = "10"
      preemptible    = false
      machine_type   = "n2-standard-8"
      team           = "devops"
      taint_key      = "instance_type"
      taint_value    = "spot"
      taint_effect   = "NO_SCHEDULE"
      auth_scopes    = "https://www.googleapis.com/auth/cloud-platform"
    }
  }
}

variable "service-account" {
  type = map(string)
  default = {
    account_id = "service-a"
  }
}

variable "project-iam-member" {
  type = map(string)
  default = {
    role = "roles/iam.workloadIdentityUser"
    # member = "serviceAccount:${google_service_account.service-a.email}"
  }
}

variable "account-iam-member" {
  type = map(string)
  default = {
    role   = "roles/iam.workloadIdentityUser"
    member = "serviceAccount:agwe-3.svc.id.goog[staging/service-a]"
  }
}
