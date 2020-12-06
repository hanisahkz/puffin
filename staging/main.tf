// TODO: Organize into modules
terraform {
  required_providers {
    google-vm = {
      source  = "hashicorp/google"
      version = "~> 3.49.0"
    }
  }

  backend "gcs" {
    bucket      = "puffin"
    prefix      = "staging"
    credentials = "puffin.json"
  }
}

provider "google-vm" {
  credentials = "puffin.json"
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

## Resources
## Network
resource "google_compute_network" "vpc_network" {
  name = var.network_name
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

  target_tags   = var.web_vm_tags
  source_ranges = ["0.0.0.0/0"]
  // source_ranges = ["202.176.5.119"] // whitelisted IPs
}

## Compute Engine
resource "google_compute_instance" "web_vm" {
  name                    = var.web_vm_name
  metadata_startup_script = file("startup.sh")
  machine_type            = var.web_vm_machine_type
  zone                    = var.zone

  tags                    = var.web_vm_tags

  boot_disk {
    initialize_params {
      image = var.web_vm_disk_image
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }
}

resource "google_compute_autoscaler" "web_vm" {
  name   = var.web_vm_name
  zone   = var.zone
  target = google_compute_instance_group_manager.web_vm.id

  autoscaling_policy {
    max_replicas    = var.web_vm_autoscaler_max_replicas
    min_replicas    = var.web_vm_autoscaler_min_replicas
    cooldown_period = var.web_vm_autoscaler_cooldown

    cpu_utilization {
      target = var.web_vm_autoscaler_cpu_util
    }
  }
}

resource "google_compute_instance_template" "web_vm" {
  name           = var.web_vm_name
  machine_type   = var.web_vm_machine_type
  can_ip_forward = false

  tags = var.web_vm_instance_groups_tags

  disk {
    source_image = data.google_compute_image.debian_9.id
  }

  network_interface {
    network = "default"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

# Target pool - for backend
resource "google_compute_target_pool" "web_vm" {
  name    = var.web_vm_target_pool_name
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance_group_manager" "web_vm" {
  name    = var.web_vm_instance_group_manager_name
  zone    = var.zone
  project = var.project_id

  version {
    instance_template  = google_compute_instance_template.web_vm.id
    name               = "primary"
  }

  target_pools       = [google_compute_target_pool.web_vm.id]
  base_instance_name = var.web_vm_name
}

# Source: https://registry.terraform.io/modules/GoogleCloudPlatform/lb/google/latest
module "load_balancer" {
  source       = "GoogleCloudPlatform/lb/google"
  version      = "~> 2.3.0"
  region       = var.region
  name         = var.web_vm_instance_lb_name
  service_port = 80
  target_tags  = [ google_compute_target_pool.web_vm.name ]
  network      = google_compute_network.vpc_network.name
}


data "google_compute_image" "debian_9" {
  family  = "debian-9"
  project = "debian-cloud"
}