output "master_internal_ip" {
  description = "Internal IP of master (first VM)"
  value       = google_compute_instance.k8s_vm[0].network_interface[0].network_ip
}

output "worker_internal_ips" {
  description = "List of internal IPs of workers"
  value       = [for idx, inst in google_compute_instance.k8s_vm : inst.network_interface[0].network_ip if idx != 0]
}
