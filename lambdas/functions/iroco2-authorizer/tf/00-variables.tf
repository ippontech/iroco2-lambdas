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
  default     = "authorizer"
}

variable "project_type" {
  type        = string
  description = "The type of project."
  default     = "application"
}

variable "cors_allowed_origins" {
  description = "The allowed origins for the CORS."
}

variable "clerk_public_key" {
  description = "cle public de clerk"
  type        = string
  default     = "clerk_public_key"
}

variable "clerk_issuer" {
  description = "issuer de clerk"
  type        = string
  default     = "clerk_issuer"
}

variable "clerk_audience" {
  description = "audience de clerk"
  type        = string
  default     = "clerk_audience"
}
