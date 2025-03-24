resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags = {
    name        = "eks-key-${var.application}-${var.environment}"
    Application = var.application
    Environment = var.environment
  }
}