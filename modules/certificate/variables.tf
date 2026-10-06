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
