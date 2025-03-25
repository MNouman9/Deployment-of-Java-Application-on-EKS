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
# Cluster Autoscaler
################################################################################
module "cluster_auto_scaler_iam" {
  source = "../../Modules/iam-role-for-service-accounts-eks"

  role_name                        = "${var.application}-${var.environment}_eks_CA"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [module.eks.cluster_name]
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

resource "helm_release" "cluster_autoscaler_release" {
  depends_on = [module.eks, module.cluster_auto_scaler_iam]
  name       = "${lower(module.eks.cluster_name)}-ca"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"

  namespace = "kube-system"

  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cluster_auto_scaler_iam.iam_role_arn
  }
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
  source      = "../../Modules/ACM"
  environment = var.environment
  application = var.application
  region      = var.region
  domain_name = var.app_domain_name
}


################################################################################
# Ingress
################################################################################
module "app_ingress" {
  source      = "../../Modules/kubernetes-ingress"
  environment = var.environment
  depends_on = [
    module.eks,
    module.app_certificate
  ]
  namespace          = "${var.environment}-${var.application}"
  app_name           = "java"
  lb_name            = var.lb_name
  service_name       = "${var.environment}-${var.application}-svc"
  ingress_group_name = "${var.application}-${var.environment}-ingress-group"
  certificate_arn    = module.app_certificate.certificate_arn
  application        = var.application
  healthcheck_path   = "/"
  url                = var.app_domain_name
}