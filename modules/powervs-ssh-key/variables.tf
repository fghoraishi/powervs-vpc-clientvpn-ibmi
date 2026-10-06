variable "name" {
  type        = string
  description = "User defined name for the SSH key in Power Virtual Server"
}

variable "power_workspace_id" {
  type        = string
  description = "The GUID of the Power Virtual Server workspace"
}

variable "ssh_key" {
  type        = string
  description = "SSH RSA public key value"
}
