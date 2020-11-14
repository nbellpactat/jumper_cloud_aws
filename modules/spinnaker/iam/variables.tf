variable "spinnaker_iam_user_name" {
  type        = string
  description = "Name for the IAM User for Spinnaker"
  default     = "spinnaker-iam-user"
}

variable "spinnaker_base_role_name" {
  type        = string
  description = "Name for the Base IAM Role for Spinnaker"
  default     = "spinnaker-base-role"
}

variable "spinnaker_base_role_desc" {
  type    = string
  default = "Role that is passed on to application instances deployed by Spinnaker"
}

variable "spinnaker_role_name" {
  type        = string
  description = "Name for the Base IAM Role for Spinnaker"
  default     = "spinnaker-role"
}

variable "spinnaker_role_desc" {
  type    = string
  default = "Role that is used by spinnaker to deploy resources and pass the Base IAM Role"
}