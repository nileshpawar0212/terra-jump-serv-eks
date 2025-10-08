resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_iam_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  tags = merge(
    {
      Name = var.cluster_name
    },
    var.tags
  )
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [aws_eks_cluster.this]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on               = [aws_eks_node_group.this]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on               = [aws_eks_node_group.this]
}

resource "aws_eks_addon" "cloudwatch" {
  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "amazon-cloudwatch-observability"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on               = [aws_eks_node_group.this]
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "eks-pod-identity-agent"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on               = [aws_eks_node_group.this]
}

