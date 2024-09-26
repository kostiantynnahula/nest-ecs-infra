variable "region" {
  description = "The region in which the resources will be created."
  default     = "eu-west-1"
}

variable "organization_db_name" {
  description = "The name of the organization database."
  default     = "organization"
}

variable "patient_db_name" {
  description = "The name of the patient database."
  default     = "patient"
}

variable "container_image" {
  type        = string
  description = "(optional) describe your variable"
  default     = "524147404421.dkr.ecr.eu-west-1.amazonaws.com/nest-ecr-organization:966d5f1-2024-09-26-11-37"
}
