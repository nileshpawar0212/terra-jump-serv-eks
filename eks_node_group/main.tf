resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  # Ensure the EKS cluster is created before the node group
  depends_on = [
    # This dependency is implicit through cluster_name, but can be made explicit if needed
  ]

  tags = merge(
    {
      "Name" = var.node_group_name
    },
    var.tags
  )
}