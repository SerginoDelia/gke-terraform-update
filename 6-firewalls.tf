# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
resource "google_compute_firewall" "allow-ssh" {
  name    = var.allow-ssh.name
  network = google_compute_network.main.name

  allow {
    protocol = var.allow-ssh.protocol
    ports    = [var.allow-ssh.ports]
  }

  source_ranges = [var.allow-ssh.source_ranges]
}
