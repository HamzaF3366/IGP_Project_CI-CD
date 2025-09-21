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
  project = var.project_id
  region  = var.region
  zone    = var.zone
  # Authentication will use GOOGLE_APPLICATION_CREDENTIALS env var set by Jenkins
}

resource "google_compute_network" "vpc_network" {
  name                    = "k8s-network"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "k8s_fw" {
  name    = "k8s-fw"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = [
      "22",            # SSH
      "80",            # HTTP
      "443",           # HTTPS
      "6443",          # Kubernetes API server
      "2379-2380",     # etcd
      "10250", "10251", "10252", # kubelet & control plane
      "30000-32767"    # NodePort services
    ]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["k8s"]
}}

resource "google_compute_instance" "k8s_vm" {
  count        = var.vm_count
  name         = "k8s-vm-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }

  tags = ["k8s"]

  metadata = {
    # remove any newline characters from the public key so metadata entry is valid
    ssh-keys = "${var.ssh_user}:${replace(var.jenkins_ssh_pub, "\n", "")}"
  }
}
