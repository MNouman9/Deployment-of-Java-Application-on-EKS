variable "environment" {
  type        = string
  description = "Name of the Environment"
}
variable "vpc_id" {
  description = "The VPC ID."
}

variable "application" {
  description = "The name of the application."
}

variable "public_access_cidr_blocks" {
  description = "List of cidr blocks for public access to the environment."
  type        = list(string)
}