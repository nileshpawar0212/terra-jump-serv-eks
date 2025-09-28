variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "iam_role_name" {
  type = string
}

variable "attach_admin_policy" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ssh_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ami_id" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "key_name" {
  type    = string
  default = "demo-eks"
}

variable "public_key_path" {
  description = "Path to the public key file on the local machine (optional). If provided, module will create the key pair in AWS."
  type        = string
  default     = ""
}

variable "private_ip" {
  description = "Optional specific private IP to assign to the instance (e.g. 192.168.101.10). Leave empty to let AWS assign one." 
  type        = string
  default     = ""
}

variable "associate_public_ip" {
  description = "Whether to associate a public IP (and allocate an EIP). Set to false to keep the instance private-only." 
  type        = bool
  default     = true
}
