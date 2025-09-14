variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "node_group_name" {
  description = "Name of the EKS node group."
  type        = string
  default     = "demo-eks-node"
}

variable "node_role_arn" {
  description = "ARN of the IAM role to associate with the node group."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to deploy the node group into."
  type        = list(string)
}

variable "launch_template_id" {
  description = "ID of the launch template."
  type        = string
}

variable "launch_template_version" {
  description = "Version of the launch template."
  type        = string
}

variable "desired_size" {
  description = "Desired number of nodes in the node group."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of nodes in the node group."
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of nodes in the node group."
  type        = number
  default     = 1
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}