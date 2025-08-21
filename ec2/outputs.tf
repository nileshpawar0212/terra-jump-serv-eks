output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "eip_allocation_id" {
  value = length(aws_eip.this) > 0 ? aws_eip.this[0].allocation_id : null
}
