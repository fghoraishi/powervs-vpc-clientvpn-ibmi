##############################################################################
# IBMi Instance Variables
##############################################################################

variable "instance_name" {
  type        = string
  description = "Name of the IBMi Power Virtual Server instance."
}

variable "power_workspace_id" {
  type        = string
  description = "The GUID of the Power Virtual Server workspace in which to create the IBMi instance."
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the SSH key in the Power workspace to inject into the IBMi instance."
}

variable "network_name" {
  type        = string
  description = "Name of the Power Virtual Server network to attach the IBMi instance to."
}

# ----------------------------------------------------------------------------
# OS Image
# ----------------------------------------------------------------------------

variable "image_name" {
  type        = string
  description = <<-EOD
    The stock image name for the IBMi OS.
    Common values:
      IBMi-7.5-09-2024-1  (IBM i 7.5)
      IBMi-7.4-09-2024-1  (IBM i 7.4)
      IBMi-7.3-09-2024-1  (IBM i 7.3)
    Run `ibmcloud pi images` inside the workspace to list available images.
  EOD
  default     = "IBMi-7.5-09-2024-1"
}

# ----------------------------------------------------------------------------
# Machine / Compute
# ----------------------------------------------------------------------------

variable "sys_type" {
  type        = string
  description = <<-EOD
    Machine type (processor architecture) for the IBMi instance.
    Supported values: s922, s1022, e980, e1080.
  EOD
  default     = "s922"

  validation {
    condition     = contains(["s922", "s1022", "e980", "e1080"], var.sys_type)
    error_message = "sys_type must be one of: s922, s1022, e980, e1080."
  }
}

variable "proc_type" {
  type        = string
  description = <<-EOD
    Processor entitlement type.
    - shared   : capped shared processor
    - uncapped : uncapped shared processor
    - dedicated: dedicated processor core
  EOD
  default     = "shared"

  validation {
    condition     = contains(["shared", "uncapped", "dedicated"], var.proc_type)
    error_message = "proc_type must be one of: shared, uncapped, dedicated."
  }
}

variable "processors" {
  type        = number
  description = <<-EOD
    Number of processor cores to allocate.
    For shared/uncapped this is the entitled capacity (e.g. 0.25, 0.5, 1, 2).
    For dedicated this must be a whole number (e.g. 1, 2, 4).
  EOD
  default     = 1
}

variable "memory" {
  type        = number
  description = "Amount of memory (GB) to allocate to the IBMi instance."
  default     = 4
}

# ----------------------------------------------------------------------------
# Storage — boot volume
# ----------------------------------------------------------------------------

variable "storage_type" {
  type        = string
  description = <<-EOD
    Storage tier for the boot volume.
    Supported values: tier1, tier3, tier5k.
    tier1  = NVMe-based flash (best performance)
    tier3  = SSD flash
    tier5k = 5k RPM (lowest cost)
  EOD
  default     = "tier3"

  validation {
    condition     = contains(["tier1", "tier3", "tier5k"], var.storage_type)
    error_message = "storage_type must be one of: tier1, tier3, tier5k."
  }
}

# ----------------------------------------------------------------------------
# Additional data disks
# ----------------------------------------------------------------------------

variable "additional_disks" {
  type = list(object({
    name  = string
    size  = number       # GB
    type  = string       # tier1 | tier3 | tier5k
    shareable = optional(bool, false)
  }))
  description = <<-EOD
    List of additional data volumes to create and attach to the IBMi instance.
    Each entry requires:
      name      - volume name (string)
      size      - size in GB (number)
      type      - storage tier: tier1, tier3, or tier5k
      shareable - whether the volume can be shared across instances (default false)
    Example:
      additional_disks = [
        { name = "data1", size = 100, type = "tier1" },
        { name = "logs",  size = 50,  type = "tier3", shareable = false }
      ]
  EOD
  default     = []

  validation {
    condition     = alltrue([for d in var.additional_disks : contains(["tier1", "tier3", "tier5k"], d.type)])
    error_message = "Each additional_disk type must be one of: tier1, tier3, tier5k."
  }
}
