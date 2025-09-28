module "vpc" {
  source       = "./vpc"
  project_name = "jump-jenkins"
  environment  = "demo"
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
  instance_type     = "t3.small"
  ssh_cidr_blocks   = ["0.1.2.3/32"]
  public_key_path   = "./demo-eks.pub"
  tags = {
    Environment = "demo"
  }
  associate_public_ip = true
}

module "eks" {
  source = "./eks"

  cluster_name            = "demo-eks"
  cluster_iam_role_arn    = module.iam.eks_cluster_role_arn
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnets
  cluster_version         = "1.33"
  node_role_arn           = module.iam.eks_node_role_arn
  launch_template_id      = module.launch_template.id
  launch_template_version = module.launch_template.latest_version

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

resource "aws_security_group_rule" "node_to_cluster_443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = module.launch_template.node_security_group_id
  security_group_id        = module.eks.cluster_primary_security_group_id
  description              = "Allow worker nodes to connect to the EKS cluster API"
}

resource "aws_security_group_rule" "jump_to_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.ec2.security_group_id
  security_group_id        = module.eks.cluster_primary_security_group_id
  description              = "Allow all traffic from the jump server"
}

resource "aws_security_group_rule" "nodes_to_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.launch_template.node_security_group_id
  security_group_id        = module.eks.cluster_primary_security_group_id
  description              = "Allow all traffic from the EKS nodes"
}