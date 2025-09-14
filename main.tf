module "vpc" {
  source = "./vpc"
}

module "iam" {
  source                = "./iam"
  eks_cluster_role_name = "demo-eks-cluster-role"
  eks_node_role_name    = "demo-eks-node-role"
  tags = {
    Environment = "demo"
  }
}

module "ec2" {
  source            = "./ec2"
  name              = "eks-jump-server"
  iam_role_name     = "demo-eks-jump-role"
  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.public_subnets[0]
  instance_type     = "t3.medium"
  ssh_cidr_blocks   = ["106.215.180.79/32"]
  public_key_path   = "./demo-eks.pub"
  tags = {
    Environment = "demo"
  }
  associate_public_ip = true
}

module "eks" {
  source = "./eks"

  cluster_name         = "demo-eks"
  cluster_iam_role_arn = module.iam.eks_cluster_role_arn
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnets
  cluster_version      = "1.30" # Specify your desired version here

  tags = {
    Environment = "demo"
  }
}

module "launch_template" {
  source = "./launch_template"

  vpc_id                    = module.vpc.vpc_id
  cluster_security_group_id = module.eks.cluster_primary_security_group_id
  key_name                  = "demo-eks" # Make sure a key pair named 'demo-eks' exists in your AWS account

  tags = {
    Environment = "demo"
  }
}

module "eks_node_group" {
  source = "./eks_node_group"

  cluster_name            = module.eks.cluster_name
  node_role_arn           = module.iam.eks_node_role_arn
  subnet_ids              = module.vpc.private_subnets
  launch_template_id      = module.launch_template.id
  launch_template_version = module.launch_template.latest_version

  tags = {
    Environment = "demo"
  }

  depends_on = [module.eks, module.launch_template]
}