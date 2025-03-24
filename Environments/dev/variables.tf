variable "environment" {
  type        = string
  description = "Name of the Environment"
}

variable "region" {
  type        = string
  description = "AWS region for all resources."
}

variable "application" {
  type        = string
  description = "The name of the application."
}

################################################################################
# Ingress
################################################################################
variable "app_domain_name" {
  type        = string
  description = "Domain name of api"
}


################################################################################
# EKS variables
################################################################################
variable "eks_kubernetes_version" {
  description = "Kubernetes version of eks cluster and nodes."
  type        = string
}

variable "eks_map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
}

variable "eks_worker_node_instance_type" {
  description = "Instance type of the worker nodes."
  type        = string
}

variable "eks_node_group_desired_size" {
  description = "Desired number of worker nodes for eks cluster"
  type        = number
}

variable "eks_node_group_min_size" {
  description = "Min number of worker nodes for eks cluster"
  type        = number
}

variable "eks_node_group_max_size" {
  description = "Max number of worker nodes for eks cluster"
  type        = number
}

variable "eks_key_arn" {
  type        = string
  description = "Kms key used for eks secrets."
}

variable "public_access_cidr_blocks" {
  description = "List of cidr blocks for public access to the environment."
  type        = list(string)
}

variable "logging_bucket_arn" {
  type        = string
  description = "Arn of the bucket used for logging."
}

################################################################################
# VPC variables
################################################################################
variable "vpc_cidr_block" {
  description = "cidr block for vpc"
}

variable "vpc_cidr_block_private_subnet_a" {
  description = "cidr block for private subnet a"
}

variable "vpc_cidr_block_private_subnet_b" {
  description = "cidr block for private subnet b"
}

variable "vpc_cidr_block_private_subnet_c" {
  description = "cidr block for private subnet c"
}

variable "vpc_cidr_block_public_subnet_a" {
  description = "cidr block for public subnet a"
}

variable "vpc_cidr_block_public_subnet_b" {
  description = "cidr block for public subnet b"
}

variable "vpc_cidr_block_public_subnet_c" {
  description = "cidr block for public subnet c"
}

################################################################################
# ALB variables
################################################################################
variable "lb_name" {
  type        = string
  description = "Load Balancer Name"
}