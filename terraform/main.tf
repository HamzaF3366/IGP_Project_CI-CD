provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_firewall" "k8s_fw" {
  name    = "k8s-fw"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "6443", "2379-2380", "10250", "10251", "10252", "30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["k8s"]
}

resource "google_compute_instance" "master" {
  name         = "k8s-master"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["k8s"]

  boot_disk {
    initialize_params { image = "ubuntu-os-cloud/ubuntu-2204-lts" }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${replace(var.jenkins_ssh_pub, "\n", "")}"
  }
}

resource "google_compute_instance" "worker" {
  name         = "k8s-worker"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["k8s"]

  boot_disk {
    initialize_params { image = "ubuntu-os-cloud/ubuntu-2204-lts" }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${replace(var.jenkins_ssh_pub, "\n", "")}"
  }
}
