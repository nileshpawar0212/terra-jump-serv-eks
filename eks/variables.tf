variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "demo-eks"
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.33"
}

variable "cluster_iam_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the cluster will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the EKS cluster."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "node_role_arn" {
  description = "The ARN of the IAM role for the EKS node group."
  type        = string
}

variable "launch_template_id" {
  description = "The ID of the launch template for the node group."
  type        = string
}

variable "launch_template_version" {
  description = "The version of the launch template."
  type        = string
}