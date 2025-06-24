provider "google" {
  project = "upgradlabs-1750647672143"  # TODO: Replace with your GCP project ID
  region  = "us-central1"
  zone    = "us-central1-a"
}

# TODO: Define a custom VPC named 'simple-vpc'
resource "google_compute_network" "custom_network" {
  name                    = "simple-vpc"
  auto_create_subnetworks = false
}
# TODO: Define a subnet named 'simple-subnet' with IP range 10.0.1.0/24
resource "google_compute_subnetwork" "custom_subnet" {
  name          = "simple-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.custom_network.id
}

# TODO: Define a VM named 'simple-vm' with:
# - Machine type: e2-micro
# - Boot disk with Debian 11
# - External IP
# - Startup script writing a log file
resource "google_compute_firewall" "allow-ssh-http" {
  name    = "allow-ssh-http"
  network = google_compute_network.custom_network.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "vm_instance" {
  name         = "simple-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.custom_network.id
    subnetwork = google_compute_subnetwork.custom_subnet.id
    access_config {} # Allocates an external IP
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "Hello from startup script!" > /var/log/startup-script.log
    date >> /var/log/startup-script.log
  EOT

}
