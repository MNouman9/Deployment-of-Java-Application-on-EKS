data "aws_iam_policy_document" "eks_alb_controller_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(flatten(concat(aws_eks_cluster.cluster.identity[*].oidc[0].issuer, [""]))[0], "https://", "")}:sub"

      values = [
        "system:serviceaccount:${var.eks_alb_namespace}:${var.eks_alb_service_account_name}",
      ]
    }

    effect = "Allow"
  }
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}
