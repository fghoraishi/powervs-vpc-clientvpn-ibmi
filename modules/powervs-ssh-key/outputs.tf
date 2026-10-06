output "ssh_key_id" {
  value       = ibm_pi_key.ssh_key.id
  description = "ID of the created PowerVS SSH key"
}

output "ssh_key_name" {
  value       = ibm_pi_key.ssh_key.pi_key_name
  description = "Name of the created PowerVS SSH key"
}
