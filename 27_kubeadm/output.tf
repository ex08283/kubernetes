# Output the public IP of the master node
output "master_public_ip" {
  description = "Public IP address of the master node"
  value       = azurerm_public_ip.master_ip.ip_address
}

# Output the public IPs of all worker nodes
output "worker_public_ips" {
  description = "Public IP addresses of the worker nodes"
  value       = [for ip in azurerm_public_ip.worker_ips : ip.ip_address]
}

# Optional: Output the private IPs of master and workers
output "master_private_ip" {
  description = "Private IP address of the master node"
  value       = azurerm_network_interface.master_nic.ip_configuration[0].private_ip_address
}

output "worker_private_ips" {
  description = "Private IP addresses of the worker nodes"
  value       = [for nic in azurerm_network_interface.worker_nics : nic.ip_configuration[0].private_ip_address]
}
