variable "content" {
  description = "plaintext data"
  type        = string
  sensitive   = true
}

variable "key" {
  description = "Key name for COS object"
  type        = string
}

variable "instance_name" {
  description = "COS instance name. If empty or not found, a new standard COS instance is created."
  type        = string
  default     = ""
}

variable "bucket_name" {
  description = "Name of bucket to create key in"
  type        = string
}

variable "name" {
  description = "Resource name prefix"
  type        = string
  default     = ""
}

variable "bucket_region" {
  description = "Region bucket will be created in"
  type        = string
}

variable "resource_group_id" {
  description = "Resource group ID for COS service instance"
  type        = string
}
