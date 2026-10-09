##############################################################################
# Account Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "REQUIRED - Provide the IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "power_workspace_location" {
  description = <<-EOD
    REQUIRED - The location used to create the power workspace.

    Available locations are: dal10, dal12, us-south, us-east, wdc06, wdc07, sao01, sao04, tor01, mon01, eu-de-1, eu-de-2, lon04, lon06, syd04, syd05, tok04, osa21, mad02, mad04.
    Please see [PowerVS Locations](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-creating-power-virtual-server) for a complete list of PowerVS locations.
  EOD
  type        = string
}

variable "resource_group_name" {
  description = <<-EOD
    OPTIONAL - Resource Group to create new resources in (Resource Group name is case sensitive).

    This will also be used to locate your existing Secrets Manager and Cloud Object Storage instance.
    If the Secrets Manager or Cloud Object Storage instance is in a different resource group, use the optional
    variables `secret_manager_resource_group_name` and `cos_instance_resource_group_name`, respectively, to specify those.
  EOD
  type        = string
  default     = "Default"
}

variable "secret_manager_name" {
  description = <<-EOD
    The Secrets Manager instance name to create the VPN certificate in.
    If left empty or if no existing instance with this name is found, a new Secrets Manager instance (Standard plan) will be provisioned.

    The Secrets Manager may be in any Resource Group or Region.
    By default, the Resource Group specified by the variable `resource_group_name` will be used.
    However, if the Secrets Manager is in another Resource Group use the optional variable `secret_manager_resource_group_name` to specify it.
  EOD
  type        = string
  default     = ""
}

variable "cos_instance_name" {
  description = <<-EOD
    The Cloud Object Storage instance name used to create a bucket with the OVPN configuration file in.
    If left empty or if no existing instance with this name is found, a new COS instance (Standard plan) and a Smart Tier regional bucket will be provisioned.
    The configuration file is used with OpenVPN Connect to connect your remote machine with the VPN created in IBM Cloud.

    The COS instance may be in any Resource Group.
    By default, the Resource Group specified by the variable `resource_group_name` will be used.
    However, if the COS instance is in another Resource Group use the optional variable `cos_instance_resource_group_name` to specify it.
  EOD
  type        = string
  default     = ""
}

variable "name" {
  description = <<-EOD
    REQUIRED - The name used for the various new Power Workspace, Transit Gateway, and VPC, secrete manager, cos, etc..
    Other resources created will use this for their basename and be suffixed by a random identifier.
  EOD
  type        = string
}

variable "secret_manager_resource_group_name" {
  description = <<-EOD
    Optional variable to specify the Resource Group the Secret Manager is in.
    If not supplied, the value specified for `resource_group_name` will be used to locate your Secrets Manager.
  EOD
  type        = string
  default     = "Default"
}

variable "cos_instance_resource_group_name" {
  description = <<-EOD
    Optional variable to specify the Resource Group the Cloud Object Storage instance is in.
    If not supplied, the value specified for `resource_group_name` will be used to locate your COS instance.
  EOD
  type        = string
  default     = "Default"
}

variable "transit_gateway_name" {
  description = <<-EOD
    OPTIONAL -  variable to specify the name of an existing transit gateway, if supplied it will be assumed that you've connected
    your power workspace to it. A connection to the VPC containing the VPN Server will be added, but not for the Power Workspace.
    Supplying this variable will also suppress Power Workspace creation.
  EOD
  type        = string
  default     = ""
}

variable "power_cloud_connection_speed" {
  description = <<-EOD
    OPTIONAL - variable to specify the speed of the cloud connection (speed in megabits per second).
    This only applies to locations WITHOUT Power Edge Routers.

    Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Default Value is 1000.
  EOD
  type        = number
  default     = 1000
}

variable "power_workspace_name" {
  description = <<-EOD
    OPTIONAL -  variable to specify the name of an existing power workspace.
    If supplied the workspace will be used to connect the VPN with.
  EOD
  type        = string
  default     = ""
}

variable "vpn_subnet_cidr" {
  description = <<-EOD
    OPTIONAL -  variable to specify the CIDR for subnet the VPN will be in. You should only need to change this
    if you have a conflict with your Power Workstation Subnets or with a VPC connected with this solution.
  EOD
  type        = string
  default     = "10.134.0.0/28"
}

variable "vpn_client_cidr" {
  description = <<-EOD
    OPTIONAL -  variable to specify the CIDR for VPN client IP pool space. This is the IP space that will be
    used by machines connecting with the VPN. You should only need to change this if you have a conflict
    with your local network.
  EOD
  type        = string
  default     = "192.168.8.0/22"
}

variable "data_location_file_path" {
  description = <<-EOD
    OPTIONAL - variable to specify Where the file with PER location data is stored. This variable is used
    for testing, and should not normally need to be altered.
  EOD
  type        = string
  default     = "./data/locations.yaml"
}

variable "create_default_vpc_address_prefixes" {
  description = <<-EOD
    OPTIONAL - variable to indicate whether a default address prefix should be created for each zone in this VPC.
  EOD
  type        = bool
  default     = false
}

##############################################################################
# PowerVS SSH Key & Subnet Variables
##############################################################################

variable "powervs_ssh_public_key" {
  description = <<-EOD
    Public SSH key string starting with ssh-rsa to import into the Power Virtual Server workspace.
    If provided, an SSH key resource will be created in the PowerVS workspace
    and automatically used for the IBMi instance (unless overridden).
  EOD
  type        = string
  default     = ""
}

variable "powervs_ssh_key_name" {
  description = <<-EOD
    Name for the PowerVS SSH key created from `powervs_ssh_public_key`.
    If left empty and `powervs_ssh_public_key` is provided, defaults to generated resource name prefix.
  EOD
  type        = string
  default     = ""
}

variable "powervs_subnet_name" {
  description = <<-EOD
    Name for the Power Virtual Server subnet network to create.
    If left empty but `powervs_subnet_cidr` is provided, defaults to `<name>-net`.
  EOD
  type        = string
  default     = ""
}

variable "powervs_subnet_cidr" {
  description = <<-EOD
    CIDR block for the Power Virtual Server subnet network to create in the PowerVS workspace (e.g. 192.168.100.0/24).
    When provided, the subnet network will be created and automatically attached to the IBMi instance.
  EOD
  type        = string
  default     = ""
}

variable "powervs_subnet_type" {
  description = <<-EOD
    OPTIONAL - Type of PowerVS subnet network to create.
    Supported values: vlan (private) or pub-vlan (public). Default is vlan.
  EOD
  type        = string
  default     = "vlan"
}

variable "powervs_subnet_gateway" {
  description = <<-EOD
    OPTIONAL - Gateway IP address for the PowerVS subnet network.
    If not specified, defaults to the first usable host IP in the CIDR block.
  EOD
  type        = string
  default     = ""
}

variable "powervs_subnet_dns" {
  description = "OPTIONAL - List of DNS server IP addresses for the PowerVS subnet network."
  type        = list(string)
  default     = ["127.0.0.1"]
}

variable "powervs_subnet_ipaddress_range" {
  description = <<-EOD
    OPTIONAL - List of IP address range(s) to allocate within the PowerVS subnet network.
    Example:
      powervs_subnet_ipaddress_range = [
        {
          pi_starting_ip_address = "192.168.100.10"
          pi_ending_ip_address   = "192.168.100.250"
        }
      ]
  EOD
  type = list(object({
    pi_starting_ip_address = string
    pi_ending_ip_address   = string
  }))
  default = []
}

variable "powervs_subnet_mtu" {
  description = "OPTIONAL - Maximum Transmission Unit (MTU) for the PowerVS subnet network. Default is 1450."
  type        = number
  default     = 1450
}

##############################################################################
# IBMi Instance Variables
##############################################################################

variable "ibmi_instance_name" {
  description = <<-EOD
    Name for the IBMi Power Virtual Server instance.
    Leave empty to skip IBMi instance creation.
  EOD
  type        = string
  default     = ""
}

variable "ibmi_ssh_key_name" {
  description = <<-EOD
    Name of an existing SSH key in the Power Virtual Server workspace to inject
    into the IBMi instance. If `powervs_ssh_public_key` is provided, the newly
    created SSH key is automatically used unless this variable is explicitly set.
  EOD
  type        = string
  default     = ""
}

variable "ibmi_network_name" {
  description = <<-EOD
    Name of an existing Power Virtual Server network to attach the IBMi instance to.
    If a PowerVS subnet network is created via `powervs_subnet_name`/`powervs_subnet_cidr`,
    it is automatically attached to the IBMi instance unless this variable is explicitly set.
  EOD
  type        = string
  default     = ""
}

variable "ibmi_image_name" {
  description = <<-EOD
    Stock catalog image name for the IBMi OS to deploy.
    Common values:
      IBMi-73-13-2924-6   
      IBMi-73-13-2924-7   
      IBMi-73-13-2984-6   
      IBMi-73-13-2984-7  
      IBMi-74-12-2924-1   
      IBMi-74-12-2924-2 
      IBMi-74-12-2984-1  
      IBMi-74-12-2984-2  
      IBMi-75-07-2924-1   
      IBMi-75-07-2984-1  
      IBMi-76-01-2924-1   
      IBMi-76-01-2984-1
    Run `ibmcloud pi image lc` in the target workspace to list all available images.
  EOD
  type    = string
  default = "IBMi-75-07-2924-1"
}

variable "ibmi_sys_type" {
  description = <<-EOD
    Machine type (processor architecture) for the IBMi instance.
    Supported values: s922, s1022, e980, e1080.
  EOD
  type    = string
  default = "s922"

  validation {
    condition     = contains(["s922", "s1022", "e980", "e1080", "power11"], var.ibmi_sys_type)
    error_message = "ibmi_sys_type must be one of: s922, s1022, e980, e1080, power11."
  }
}

variable "ibmi_proc_type" {
  description = <<-EOD
    Processor entitlement type for the IBMi instance.
    - shared    : capped shared processor
    - uncapped  : uncapped shared processor
    - dedicated : dedicated processor core
  EOD
  type    = string
  default = "shared"

  validation {
    condition     = contains(["shared", "uncapped", "dedicated"], var.ibmi_proc_type)
    error_message = "ibmi_proc_type must be one of: shared, uncapped, dedicated."
  }
}

variable "ibmi_processors" {
  description = <<-EOD
    Number of processor cores to allocate to the IBMi instance.
    For shared/uncapped this is the entitled capacity (e.g. 0.25, 0.5, 1, 2).
    For dedicated this must be a whole number (e.g. 1, 2, 4).
  EOD
  type    = number
  default = 0.25
}

variable "ibmi_memory" {
  description = "Amount of memory in GB to allocate to the IBMi instance."
  type        = number
  default     = 2
}

variable "ibmi_storage_type" {
  description = <<-EOD
    Storage tier for the IBMi boot volume.
    - tier1  : NVMe-based flash (highest performance)
    - tier3  : SSD flash (balanced)
    - tier5k : 5k RPM spinning disk (lowest cost)
  EOD
  type    = string
  default = "tier3"

  validation {
    condition     = contains(["tier0", "tier1", "tier3", "tier5k"], var.ibmi_storage_type)
    error_message = "ibmi_storage_type must be one of: tier0, tier1, tier3, tier5k."
  }
}

variable "ibmi_additional_disks" {
  description = <<-EOD
    List of additional data volumes to create and attach to the IBMi instance.
    Each entry:
      name      - volume name (string, must be unique within the workspace)
      size      - size in GB (number)
      type      - storage tier: tier0, tier1, tier3, or tier5k
      shareable - (optional) whether the volume may be shared across instances (default false)
    Example for two disks (exclude the second disk and remove comma):

      [ { name = "ibmi-data",  size = 200, type = "tier1", shareable = true },
        { name = "ibmi-logs",  size = 50,  type = "tier3", shareable = false } ]
  EOD
  type = list(object({
    name      = string
    size      = number
    type      = string
    shareable = optional(bool, false)
  }))
  default = []

  validation {
    condition     = alltrue([for d in var.ibmi_additional_disks : contains(["tier0", "tier1", "tier3", "tier5k"], d.type)])
    error_message = "Each ibmi_additional_disks entry type must be one of: tier1, tier3, tier5k."
  }
}
