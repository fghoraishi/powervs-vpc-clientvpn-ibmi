##############################################################################
# Terraform Main IaC
##############################################################################
# Generate random identifier
resource "random_string" "resource_identifier" {
  length  = 5
  upper   = false
  numeric = false
  lower   = true
  special = false
}

locals {
  uname = format("%s-%s", var.name, random_string.resource_identifier.result)
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

data "ibm_resource_group" "secret_manager" {
  name = var.secret_manager_resource_group_name == "" ? var.resource_group_name : var.secret_manager_resource_group_name
}

data "ibm_resource_group" "cos_instance" {
  name = var.cos_instance_resource_group_name == "" ? var.resource_group_name : var.cos_instance_resource_group_name
}

### commented out since it alreay exist - faad
# Authorization policy allowing VPC Client-to-Site VPN service to read secrets from Secrets Manager
#resource "ibm_iam_authorization_policy" "vpn_secrets_manager" {
#  source_service_name         = "is"
#  source_resource_type        = "vpn-server"
#  target_service_name         = "secrets-manager"
#  roles                       = ["SecretsReader"]
#  description                 = "Allow VPC VPN Server service to read secrets in Secrets Manager"
#}

module "certificate" {
  source              = "./modules/certificate"
  secret_manager_name = var.secret_manager_name
  resource_group_id   = data.ibm_resource_group.secret_manager.id
  name                = local.uname
  region              = local.location.vpc_region
#  depends_on          = [ibm_iam_authorization_policy.vpn_secrets_manager]
}

module "vpc" {
  source                    = "./modules/vpc"
  name                      = var.name
  resource_group_id         = data.ibm_resource_group.group.id
  address_prefix_management = var.create_default_vpc_address_prefixes ? "auto" : "manual"
}

module "vpn" {
  source            = "./modules/vpn"
  name              = var.name
  resource_group_id = data.ibm_resource_group.group.id
  certificate_crn   = module.certificate.server_cert_crn
  client_cidr       = var.vpn_client_cidr
  subnet_cidr       = var.vpn_subnet_cidr
  zone              = local.location.vpc_zone
  vpc_id            = module.vpc.vpc.id
}

module "ovpn" {
  source       = "./modules/ovpn"
  vpn_hostname = module.vpn.hostname
  ca           = module.certificate.ca
  client_cert  = module.certificate.client_cert
  client_key   = module.certificate.client_key
}

module "cos_upload" {
  source            = "./modules/cos-upload"
  name              = local.uname
  key               = format("%s.ovpn", var.name)
  content           = module.ovpn.data
  instance_name     = var.cos_instance_name
  bucket_name       = local.uname
  bucket_region     = local.location.vpc_region
  resource_group_id = data.ibm_resource_group.cos_instance.id
}

# If a power workspace name is provided, look it up
data "ibm_resource_instance" "power_workspace" {
  count   = var.power_workspace_name == "" ? 0 : 1
  name    = var.power_workspace_name
  service = "power-iaas"
}

# Only create a new power workspace when neither an existing
# power workspace or transit gateway are supplied
module "power" {
  count             = var.power_workspace_name == "" && var.transit_gateway_name == "" ? 1 : 0
  source            = "./modules/power"
  name              = var.name
  resource_group_id = data.ibm_resource_group.group.id
  location          = var.power_workspace_location
}

locals {
  power_workspace = var.transit_gateway_name == "" ? var.power_workspace_name == "" ? module.power[0].workspace : data.ibm_resource_instance.power_workspace[0] : null
  per_enabled     = local.location.per_enabled
}

# For locations that are not PER enabled create a Cloud Connection that is Transit Gateway enabled.
# This allows us to use the Directlink connection it created and attach it to our Transit Gateway.
# If an existing Transit Gateway is supplied, we assume that this connection (or PER) is already
# connected to the Transit Gateway and will not create the cloud connection to enable it.
module "cloud_connection" {
  count                  = var.transit_gateway_name != "" || local.per_enabled ? 0 : 1
  source                 = "./modules/cloud-connection"
  name                   = local.uname
  cloud_connection_speed = var.power_cloud_connection_speed
  power_workspace_id     = local.power_workspace.guid
  providers              = { ibm = ibm.power }
}

# Connect the VPC and Power Workspace to the Transit Gateway
# If the Workspace is PER enabled it maybe directly connected to
# the Gateway, otherwise the Directlink Gateway created by
# the Cloud Connection is used. If a Transit Gateway is
# supplied, only create the VPC connection.
locals {
  vpc_connection = {
    network_type = "vpc"
    network_id   = module.vpc.vpc.crn
  }
  power_connection = {
    network_type = "power_virtual_server"
    network_id   = var.transit_gateway_name == "" ? local.power_workspace.id : ""
  }
  directlink_connection = {
    network_type = "directlink"
    network_id   = length(module.cloud_connection) == 0 ? "" : module.cloud_connection[0].dl_gateway.crn
  }
  connections = var.transit_gateway_name != "" ? [local.vpc_connection] : local.per_enabled ? [local.vpc_connection, local.power_connection] : [local.vpc_connection, local.directlink_connection]
}

module "transit" {
  source            = "./modules/transit"
  name              = var.transit_gateway_name == "" ? var.name : var.transit_gateway_name
  region            = local.location.vpc_region
  resource_group_id = data.ibm_resource_group.group.id
  connections       = local.connections
}

locals {
  bucket_url = module.cos_upload.bucket_url
}

# Determine which workspace GUID to pass to PowerVS resources and the IBMi module.
# The workspace may have been created by this run or looked up from an existing one.
locals {
  power_workspace_guid = var.transit_gateway_name == "" ? (local.power_workspace != null ? local.power_workspace.guid : "") : (
    var.power_workspace_name != "" ? data.ibm_resource_instance.power_workspace[0].guid : ""
  )
}

# Create a PowerVS SSH Key if a public SSH key is provided
module "powervs_ssh_key" {
  count              = var.powervs_ssh_public_key != "" ? 1 : 0
  source             = "./modules/powervs-ssh-key"
  power_workspace_id = local.power_workspace_guid
  name               = var.powervs_ssh_key_name != "" ? var.powervs_ssh_key_name : local.uname
  ssh_key            = var.powervs_ssh_public_key
  providers          = { ibm = ibm.power }
}

# Create a PowerVS subnet network
module "powervs_network" {
  count              = var.powervs_subnet_name != "" || var.powervs_subnet_cidr != "" ? 1 : 0
  source             = "./modules/powervs-network"
  power_workspace_id = local.power_workspace_guid
  name               = var.powervs_subnet_name != "" ? var.powervs_subnet_name : format("%s-net", local.uname)
  cidr               = var.powervs_subnet_cidr
  gateway            = var.powervs_subnet_gateway
  dns                = var.powervs_subnet_dns
  ipaddress_range    = var.powervs_subnet_ipaddress_range
  network_type       = var.powervs_subnet_type
  mtu                = var.powervs_subnet_mtu
  providers          = { ibm = ibm.power }
}

locals {
  # Resolved SSH key name: created SSH key > explicit ibmi_ssh_key_name
  effective_ssh_key_name = length(module.powervs_ssh_key) > 0 ? module.powervs_ssh_key[0].ssh_key_name : var.ibmi_ssh_key_name

  # Resolved network name: created subnet network > explicit ibmi_network_name
  effective_network_name = length(module.powervs_network) > 0 ? module.powervs_network[0].network_name : var.ibmi_network_name
}

# Provision an IBMi instance only when ibmi_instance_name is provided
module "ibmi" {
  count  = var.ibmi_instance_name != "" ? 1 : 0
  source = "./modules/ibmi"

  power_workspace_id = local.power_workspace_guid
  instance_name      = var.ibmi_instance_name
  ssh_key_name       = local.effective_ssh_key_name
  network_name       = local.effective_network_name

  image_name       = var.ibmi_image_name
  sys_type         = var.ibmi_sys_type
  proc_type        = var.ibmi_proc_type
  processors       = var.ibmi_processors
  memory           = var.ibmi_memory
  storage_type     = var.ibmi_storage_type
  additional_disks = var.ibmi_additional_disks

  providers = { ibm = ibm.power }
}
