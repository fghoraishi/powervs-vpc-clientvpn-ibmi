variable "name" {
  type        = string
  description = "Name of the Power Virtual Server network"
}

variable "power_workspace_id" {
  type        = string
  description = "The GUID of the Power Virtual Server workspace"
}

variable "network_type" {
  type        = string
  description = "Type of network: pub-vlan or vlan (private). Default is vlan."
  default     = "vlan"
}

variable "cidr" {
  type        = string
  description = "Network CIDR (e.g. 192.168.100.0/24)"
  default     = ""
}

variable "gateway" {
  type        = string
  description = "Gateway IP address for the network (optional, defaults to first usable IP in CIDR if empty)"
  default     = ""
}

variable "dns" {
  type        = list(string)
  description = "List of DNS servers for the network"
  default     = ["127.0.0.1"]
}

variable "ipaddress_range" {
  type = list(object({
    pi_starting_ip_address = string
    pi_ending_ip_address   = string
  }))
  description = "IP address range(s) for the network"
  default     = []
}

variable "mtu" {
  type        = number
  description = "Maximum transmission unit (MTU) for the network"
  default     = 1450
}
