provider "aws" {
  region = var.region
}

resource "aws_acm_certificate" "default" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name        = var.domain_name
    Application = var.application
    Environment = var.environment
  }
}