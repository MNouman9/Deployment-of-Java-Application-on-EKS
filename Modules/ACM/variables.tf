variable "environment" {
  type        = string
  description = "Name of the Environment"
}

variable "application" {
  description = "The name of the application."
}

variable "region" {
  description = "AWS region to deploy the ACM certificate"
  type        = string
}

variable "domain_name" {
  description = "Domain name for certificate."
}