output "id" {
  description = "The ID of the launch template."
  value       = aws_launch_template.this.id
}

output "name" {
  description = "The name of the launch template."
  value       = aws_launch_template.this.name
}

output "latest_version" {
  description = "The latest version of the launch template."
  value       = aws_launch_template.this.latest_version
}

output "node_security_group_id" {
  description = "The ID of the security group created for the nodes."
  value       = aws_security_group.node_sg.id
}