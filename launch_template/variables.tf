variable "launch_template_name" {
  description = "Name of the launch template."
  type        = string
  default     = "demo-eks-lt"
}

variable "instance_type" {
  description = "Instance type for the EKS nodes."
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "The key pair name for the instances."
  type        = string
  default     = "demo-eks"
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "cluster_security_group_id" {
  description = "The ID of the EKS cluster's primary security group."
  type        = string
}

variable "node_security_group_name" {
  description = "The name for the node security group."
  type        = string
  default     = "demo-eks-node-sg"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}