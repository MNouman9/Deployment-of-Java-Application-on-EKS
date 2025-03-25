output "cluster_id" {
  value = aws_eks_cluster.cluster.id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.cluster.name
}

output "kubernetes_version" {
  description = "The Kubernetes version for the cluster"
  value       = aws_eks_cluster.cluster.version
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = try(aws_iam_openid_connect_provider.oidc_provider.arn, null)
}
