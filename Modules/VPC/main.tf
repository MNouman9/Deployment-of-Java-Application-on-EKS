resource "aws_vpc" "default" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "VPC for ${var.application}-${var.environment}"
    Application = var.application
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.default.id
  tags = {
    Application = var.application
    Environment = var.environment
  }
}

resource "aws_eip" "nat_gateway_eip" {
  tags = {
    Application = var.application
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_a.id
  depends_on    = [aws_internet_gateway.internet_gateway]
  tags = {
    Application = var.application
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name        = "public-route-table-${var.application}-${var.environment}"
    Application = var.application
    Environment = var.environment
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.internet_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name        = "private-route-table-${var.application}-${var.environment}"
    Application = var.application
    Environment = var.environment
  }
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private.id
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.default.id
  availability_zone = "${var.region}a"
  cidr_block        = var.cidr_block_private_subnet_a
  tags = {
    Name                              = "${var.application}.${var.environment}.private.subnet.a"
    Application                       = var.application
    Environment                       = var.environment
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.default.id
  availability_zone = "${var.region}b"
  cidr_block        = var.cidr_block_private_subnet_b
  tags = {
    Name                              = "${var.application}.${var.environment}.private.subnet.b"
    Application                       = var.application
    Environment                       = var.environment
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.default.id
  availability_zone = "${var.region}c"
  cidr_block        = var.cidr_block_private_subnet_c
  tags = {
    Name                              = "${var.application}.${var.environment}.private.subnet.c"
    Application                       = var.application
    Environment                       = var.environment
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.default.id
  availability_zone = "${var.region}a"
  cidr_block        = var.cidr_block_public_subnet_a
  tags = {
    Name                     = "${var.application}.${var.environment}.public.subnet.a"
    Application              = var.application
    Environment              = var.environment
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.default.id
  availability_zone = "${var.region}b"
  cidr_block        = var.cidr_block_public_subnet_b
  tags = {
    Name                     = "${var.application}.${var.environment}.public.subnet.b"
    Application              = var.application
    Environment              = var.environment
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.default.id
  availability_zone = "${var.region}c"
  cidr_block        = var.cidr_block_public_subnet_c
  tags = {
    Name                     = "${var.application}.${var.environment}.public.subnet.c"
    Application              = var.application
    Environment              = var.environment
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_default_security_group" "default" {
  vpc_id  = aws_vpc.default.id
  ingress = []
  egress  = []
}


resource "aws_flow_log" "this" {
  iam_role_arn    = aws_iam_role.this.arn
  log_destination = aws_cloudwatch_log_group.this.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.default.id
}

resource "aws_cloudwatch_log_group" "this" {
  name = "VPC-Flow-Logs"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = "vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "vpc-flow-logs-policy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.this.json
}