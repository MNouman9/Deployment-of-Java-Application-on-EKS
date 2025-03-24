################################################################################
# VPC
################################################################################
module "vpc" {
  source                      = "../../Modules/vpc"
  region                      = var.region
  environment                 = var.environment
  application                 = var.application
  cidr_block                  = var.vpc_cidr_block
  cidr_block_private_subnet_a = var.vpc_cidr_block_private_subnet_a
  cidr_block_private_subnet_b = var.vpc_cidr_block_private_subnet_b
  cidr_block_private_subnet_c = var.vpc_cidr_block_private_subnet_c
  cidr_block_public_subnet_a  = var.vpc_cidr_block_public_subnet_a
  cidr_block_public_subnet_b  = var.vpc_cidr_block_public_subnet_b
  cidr_block_public_subnet_c  = var.vpc_cidr_block_public_subnet_c
  logging_bucket_arn          = var.logging_bucket_arn
}

################################################################################
# Security Groups
################################################################################
module "securitygroups" {
  source                    = "../../Modules/securitygroups"
  environment               = var.environment
  application               = var.application
  vpc_id                    = module.vpc.vpc_id
  public_access_cidr_blocks = var.public_access_cidr_blocks
}

################################################################################
# EKS Cluster
################################################################################
module "eks" {
  source                       = "../../Modules/eks"
  environment                  = var.environment
  application                  = var.application
  kubernetes_version           = var.eks_kubernetes_version
  cluster_name                 = "${var.application}-eks-cluster-${var.environment}"
  cluster_security_group_ids   = module.securitygroups.eks_cluster_security_group_ids
  vpc_id                       = module.vpc.vpc_id
  public_access_cidr_blocks    = var.public_access_cidr_blocks
  subnet_ids                   = module.vpc.private_subnets
  eks_key_arn                  = var.eks_key_arn
  workers_instance_types       = [var.eks_worker_node_instance_type]
  worker_security_group_ids    = module.securitygroups.eks_workers_security_group_ids
  node_group_desired_size      = var.eks_node_group_desired_size
  node_group_min_size          = var.eks_node_group_min_size
  node_group_max_size          = var.eks_node_group_max_size
  eks_alb_service_account_name = "aws-load-balancer-controller"
  region                       = var.region
  map_users                    = var.eks_map_users
}

################################################################################
# Logging
################################################################################
module "logging" {
  source      = "../../Modules/logging"
  environment = var.environment
  application = var.application
}

################################################################################
# KMS
################################################################################
module "kms" {
  source      = "../../Modules/KMS"
  environment = var.environment
  application = var.application
}

################################################################################
# ACM Certificates
################################################################################
module "app_certificate" {
  source          = "../../Modules/ACM"
  environment     = var.environment
  application     = var.application
  region          = var.region
  domain_name     = var.app_domain_name
}


################################################################################
# Ingress
################################################################################
module "app_ingress" {
  source             = "../../Modules/kubernetes-ingress"
  environment        = var.environment
  depends_on         = [module.infrastructure.eks]
  namespace          = "${var.environment}-${var.application}"
  app_name           = "java"
  lb_name            = var.lb_name
  service_name       = "${var.environment}-${var.application}-svc"
  ingress_group_name = "${var.application}-${var.environment}-ingress-group"
  certificate_arn    = module.app_certificate.certificate_arn
  application        = var.application
  healthcheck_path   = "/"
  route53_zone_id    = module.route53.route53_zone_id
  url                = var.app_domain_name
}