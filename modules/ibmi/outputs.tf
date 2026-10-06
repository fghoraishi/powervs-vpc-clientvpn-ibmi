##############################################################################
# IBMi Instance Outputs
##############################################################################

output "instance_id" {
  value       = ibm_pi_instance.ibmi.id
  description = "CRN/ID of the IBMi Power Virtual Server instance."
}

output "instance_name" {
  value       = ibm_pi_instance.ibmi.pi_instance_name
  description = "Name of the IBMi Power Virtual Server instance."
}

output "network_interface" {
  value       = ibm_pi_instance.ibmi.pi_network
  description = "Network interface details (including the assigned IP addresses) for the IBMi instance."
}

output "additional_volume_ids" {
  value       = { for k, v in ibm_pi_volume.additional_disks : k => v.volume_id }
  description = "Map of additional data volume names to their volume IDs."
}
