terraform {
  required_providers {
    google-vm = {
      source  = "hashicorp/google"
      version = "~> 3.49.0"
    }
  }

  backend "gcs" {
    bucket  = "puffin"
    prefix  = "staging"
    credentials = "puffin.json"
  }
}

provider "google-vm" {
  credentials = "puffin.json"
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

## Resources
resource "google_compute_network" "vpc_network" {
  name = var.network_name
}

resource "google_compute_instance" "web_vm" {
  name         = var.web_vm_name
  metadata_startup_script = file("startup.sh")
  machine_type = var.web_vm_machine_type
  zone         = var.zone

  tags = var.web_vm_tags

  boot_disk {
    initialize_params {
      image = var.web_vm_disk_image
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    access_config {
    }
  }
}

resource "google_compute_firewall" "firewall" {
  name    = var.network_name
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "1000-2000"]
  }

  target_tags = var.web_vm_tags
//  source_ranges = ["0.0.0.0/0"] //
  source_ranges = ["202.176.5.119"] // VPN
}