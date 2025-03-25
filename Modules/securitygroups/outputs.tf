output "ssh_public_security_group_ids" {
  value = [
    aws_security_group.ssh_public.id
  ]
}

output "ssh_private_security_group_ids" {
  value = [
    aws_security_group.ssh_private.id
  ]
}

output "eks_cluster_security_group_ids" {
  value = [
    aws_security_group.eks_cluster.id
  ]
}

output "eks_workers_security_group_ids" {
  value = [
    aws_security_group.eks_workers.id
  ]
}