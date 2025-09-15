module "vpc" {
  source           = "terraform-aws-modules/vpc/aws"
  name             = "jump-jenkins-vpc"
  cidr             = "10.0.0.0/16"
  azs              = ["us-east-1a", "us-east-1b"]

  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway  = true
  single_nat_gateway  = true

  tags = {
    Environment = "demo"
    Name        = "jump-jenkins-vpc"
  }

  public_subnet_tags = {
    Name = "public-subnet"
    Type = "public"
  }

  private_subnet_tags = {
    Name = "private-subnet"
    Type = "private"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-subnet-public-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-subnet-private-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_eip" "nat" {
  count = length(var.private_subnets)
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip-nat-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_nat_gateway" "main" {
  count         = length(var.private_subnets)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.project_name}-nat-${data.aws_availability_zones.available.names[count.index]}"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-rt-public"
  }
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.project_name}-rt-private-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat([aws_route_table.public.id], aws_route_table.private[*].id)

  tags = {
    Name = "${var.project_name}-vpce-s3-gateway"
  }
}
