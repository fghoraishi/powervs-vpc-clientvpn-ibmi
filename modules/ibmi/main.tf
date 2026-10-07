##############################################################################
# IBMi Power Virtual Server Instance
##############################################################################

# Look up the stock OS image by name within the workspace
data "ibm_pi_catalog_images" "ibmi_images" {
  pi_cloud_instance_id = var.power_workspace_id
  sap                  = false
}

locals {
  # Find the image whose name matches var.image_name (exact match)
  image_match = [
    for img in data.ibm_pi_catalog_images.ibmi_images.images :
    img if img.name == var.image_name
  ]
  image_id = local.image_match[0].image_id
}

# Look up the network by name
data "ibm_pi_network" "network" {
  pi_cloud_instance_id = var.power_workspace_id
  pi_network_name      = var.network_name
}

# -----------------------------------------------------------------------
# Boot volume is implicitly created by ibm_pi_instance when
# storage_type and an image are supplied.
# -----------------------------------------------------------------------
resource "ibm_pi_instance" "ibmi" {
  pi_cloud_instance_id = var.power_workspace_id
  pi_instance_name     = var.instance_name

  # OS
  pi_image_id = local.image_id

  # Compute
  pi_sys_type   = var.sys_type
  pi_proc_type  = var.proc_type
  pi_processors = var.processors
  pi_memory     = var.memory

  # Boot volume storage tier
  pi_storage_type = var.storage_type

  # SSH key (must already exist in the workspace)
  pi_key_pair_name = var.ssh_key_name

  # Network
  pi_network {
    network_id = data.ibm_pi_network.network.id
  }
}

# -----------------------------------------------------------------------
# Additional data volumes
# -----------------------------------------------------------------------
resource "ibm_pi_volume" "additional_disks" {
  for_each = { for disk in var.additional_disks : disk.name => disk }

  pi_cloud_instance_id = var.power_workspace_id
  pi_volume_name       = each.value.name
  pi_volume_size       = each.value.size
  pi_volume_type       = each.value.type
  pi_volume_shareable  = each.value.shareable
}

# Attach each additional volume to the instance
resource "ibm_pi_volume_attach" "additional_disk_attach" {
  for_each = ibm_pi_volume.additional_disks

  pi_cloud_instance_id = var.power_workspace_id
  pi_instance_id       = ibm_pi_instance.ibmi.instance_id
  pi_volume_id         = each.value.volume_id
}
