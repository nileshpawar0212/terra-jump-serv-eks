module "vpc" {
  source           = "./vpc"
}


module "ec2" {
  source        = "./ec2"
  name          = "eks-jump-server"
  iam_role_name = "demo-eks-jump-role"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnets[0]
  instance_type = "t3.medium"
  ssh_cidr_blocks = ["106.215.180.79/32"]
  public_key_path = "./demo-eks.pub"
  tags = {
    Environment = "demo"
  }
  # Set to false to keep instance private-only (no public IP/EIP)
  associate_public_ip = true
  # Optionally set a specific private IP in the subnet. Example:
  # private_ip = "192.168.101.10"
}