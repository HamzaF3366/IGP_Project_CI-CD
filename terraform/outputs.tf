# Public IP of master (first VM)
output "master_public_ip" {
  description = "Public IP of the master VM"
  value       = google_compute_instance.k8s_vm[0].network_interface[0].access_config[0].nat_ip
}

# Public IPs of worker nodes (all except master)
output "worker_public_ips" {
  description = "List of public IPs of worker VMs"
  value       = [
    for idx, inst in google_compute_instance.k8s_vm :
    inst.network_interface[0].access_config[0].nat_ip if idx != 0
  ]
}
