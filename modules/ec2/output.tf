output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

# output "instance_public_ip" {
#   description = "Public IP address of the EC2 instance"
#   value       = aws_instance.this[0].public_ip
# }

# output "private_ips" {
#   description = "Private IPs of the created instances"
#   value       = aws_instance.this[*].private_ip
# }

# output "public_ips" {
#   description = "Public IPs of the created instances"
#   value       = aws_instance.this[*].public_ip
# }