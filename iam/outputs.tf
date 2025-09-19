output "eks_cluster_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  description = "The ARN of the IAM role for the EKS nodes"
  value       = aws_iam_role.eks_node_role.arn
}