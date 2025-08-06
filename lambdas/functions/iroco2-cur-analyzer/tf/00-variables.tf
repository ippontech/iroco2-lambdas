variable "namespace" {
  type        = string
  description = "The namespace in which the project is."
  default     = "iroco2"
}

variable "environment" {
  type        = string
  description = "The name of the environment we are deploying to"
}

variable "project_name" {
  type        = string
  description = "Project's name"
  default     = "cur"
}

variable "project_type" {
  type        = string
  description = "The type of project."
  default     = "application"
}

variable "front_domain_name" {
  type        = string
  description = "The name of the front."
}
