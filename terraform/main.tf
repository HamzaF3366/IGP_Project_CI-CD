terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file(var.gcp_credentials != "" ? var.gcp_credentials : getenv("GOOGLE_APPLICATION_CREDENTIALS"))
}

# Create a network
resource "google_compute_network" "vpc_network" {
  name                    = "k8s-network"
  auto_create_subnetworks = true
}

# Create firewall for SSH + Kubernetes
resource "google_compute_firewall" "default" {
  name    = "k8s-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "6443", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create VMs (1 master + 1 worker for now)
resource "google_compute_instance" "k8s_vm" {
  count        = var.vm_count
  name         = "k8s-vm-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 30
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {} # Assigns external IP
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file("~/.ssh/id_rsa.pub")}"
  }
}
