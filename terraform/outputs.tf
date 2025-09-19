# Master Node IP (first VM)
output "master_public_ip" {
  value = google_compute_instance.k8s_vm[0].network_interface[0].access_config[0].nat_ip
}

# Worker Node IPs (all except master)
output "worker_public_ips" {
  value = [for i in google_compute_instance.k8s_vm : i.network_interface[0].access_config[0].nat_ip if i.name != "k8s-vm-0"]
}
