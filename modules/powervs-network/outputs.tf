output "network_id" {
  value       = ibm_pi_network.network.network_id
  description = "ID of the created PowerVS network"
}

output "network_name" {
  value       = ibm_pi_network.network.pi_network_name
  description = "Name of the created PowerVS network"
}

output "vlan_id" {
  value       = ibm_pi_network.network.vlan_id
  description = "VLAN ID of the created PowerVS network"
}
