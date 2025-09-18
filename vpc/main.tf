provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tagging
  igw_tags = {
    Name = "${var.project_name}-igw"
  }

  nat_gateway_tags = {
    Name = "${var.project_name}-natgateway"
  }

  public_subnet_tags = {
    Type = "${var.project_name}-public"
  }

  private_subnet_tags = {
    Type = "${var.project_name}-private"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Example VPC Endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    module.vpc.public_route_table_ids,
    module.vpc.private_route_table_ids
  )

  tags = {
    Name = "${var.project_name}-vpce-s3"
  }
}
