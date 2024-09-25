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
