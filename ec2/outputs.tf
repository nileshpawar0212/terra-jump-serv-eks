output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "eip_allocation_id" {
  value = length(aws_eip.this) > 0 ? aws_eip.this[0].allocation_id : null
}

output "security_group_id" {
  description = "The ID of the security group for the EC2 instance"
  value       = aws_security_group.this.id
}
