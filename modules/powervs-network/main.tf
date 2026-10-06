resource "ibm_pi_network" "network" {
  pi_cloud_instance_id = var.power_workspace_id
  pi_network_name      = var.name
  pi_network_type      = var.network_type
  pi_cidr              = var.cidr != "" ? var.cidr : null
  pi_gateway           = var.gateway != "" ? var.gateway : null
  pi_dns               = var.dns
  pi_network_mtu       = var.mtu

  dynamic "pi_ipaddress_range" {
    for_each = var.ipaddress_range
    content {
      pi_starting_ip_address = pi_ipaddress_range.value.pi_starting_ip_address
      pi_ending_ip_address   = pi_ipaddress_range.value.pi_ending_ip_address
    }
  }
}
