variable "eks_cluster_role_name" {
  description = "Name for the EKS cluster IAM role."
  type        = string
  default     = "eks-cluster-role"
}

variable "eks_node_role_name" {
  description = "Name for the EKS node group IAM role."
  type        = string
  default     = "eks-node-group-role"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}