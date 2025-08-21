module "vpc" {
  source           = "terraform-aws-modules/vpc/aws"
  name             = "jump-jenkins-vpc"
  cidr             = "192.168.0.0/16"
  azs              = ["us-east-1a", "us-east-1b"]

  # Public subnets (unchanged)
  public_subnets   = ["192.168.101.0/24", "192.168.102.0/24"]

  # Add two private subnets (one per AZ)
  private_subnets  = ["192.168.201.0/24", "192.168.202.0/24"]

  # Enable NAT gateway so private subnets have outbound internet access
  enable_nat_gateway  = true
  # Create a single NAT gateway (set to false to create one per AZ)
  single_nat_gateway  = true

  tags = {
    Environment = "demo"
    Name        = "jump-jenkins-vpc"
  }
}
