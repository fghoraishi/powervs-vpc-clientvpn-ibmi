resource "ibm_pi_key" "ssh_key" {
  pi_cloud_instance_id = var.power_workspace_id
  pi_key_name          = var.name
  pi_ssh_key           = var.ssh_key
}
