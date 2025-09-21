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
  # Authentication uses GOOGLE_APPLICATION_CREDENTIALS env var set by Jenkins
}

# Firewall rule to allow SSH + Kubernetes traffic on the default network
resource "google_compute_firewall" "allow_ssh_k8s" {
  name    = "allow-ssh-k8s"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = [
      "22",            # SSH
      "80", "443",     # HTTP/HTTPS
      "6443",          # Kubernetes API server
      "2379-2380",     # etcd
      "10250", "10251", "10252", # kubelet + control plane
      "30000-32767"    # NodePort services
    ]
  }

  # For testing, open to all (⚠️ restrict to Jenkins IP/CIDR in production!)
  source_ranges = ["0.0.0.0/0"]

  target_tags = ["k8s"]
}

# Create N (default = 2) Ubuntu VMs for Kubernetes
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
    network = "default"
    access_config {} # Required to assign an external/public IP
  }

  tags = ["k8s"]

  metadata = {
    # Inject Jenkins SSH public key into the "ubuntu" user
    ssh-keys = "${var.ssh_user}:${replace(var.jenkins_ssh_pub, "\n", "")}"
  }
}
