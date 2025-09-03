module "vpc" {
  source           = "terraform-aws-modules/vpc/aws"
  name             = "jump-jenkins-vpc"
  cidr             = "192.168.0.0/16"
  azs              = ["us-east-1a", "us-east-1b"]

  public_subnets   = ["192.168.101.0/24", "192.168.102.0/24"]
  private_subnets  = ["192.168.201.0/24", "192.168.202.0/24"]

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
