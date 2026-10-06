##############################################################################
# Terraform Outputs
##############################################################################

output "bucket_url" {
  value       = local.bucket_url
  description = "URL to bucket containing the OVPN file"
}

output "ibmi_instance_id" {
  value       = var.ibmi_instance_name != "" ? module.ibmi[0].instance_id : null
  description = "ID of the provisioned IBMi Power Virtual Server instance (null when not created)."
}

output "ibmi_instance_name" {
  value       = var.ibmi_instance_name != "" ? module.ibmi[0].instance_name : null
  description = "Name of the provisioned IBMi Power Virtual Server instance (null when not created)."
}

output "ibmi_network_interface" {
  value       = var.ibmi_instance_name != "" ? module.ibmi[0].network_interface : null
  description = "Network interface details (IP addresses) for the IBMi instance (null when not created)."
}

output "ibmi_additional_volume_ids" {
  value       = var.ibmi_instance_name != "" ? module.ibmi[0].additional_volume_ids : null
  description = "Map of additional data volume names to volume IDs for the IBMi instance (null when not created)."
}
