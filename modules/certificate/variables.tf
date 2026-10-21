variable "name" {
  type        = string
  description = "Name for imported Secret Manager certificate."
}

variable "secret_manager_name" {
  type        = string
  description = "Name of the existing or new Secrets Manager instance."
  default     = ""
}

variable "resource_group_id" {
  description = "Resource group the secret manager is in."
  type        = string
}

variable "region" {
  type        = string
  description = "Region for the Secrets Manager instance if created."
  default     = ""
}
variable "plan" {
  description = "OPTIONAL standard or trial plan to use when creating secret manager. Trial is free for 30 days and can only be created once. Standard is paid"
  type        = string
}
