output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.selfheal_ec2.id
}

output "instance_public_ip" {
  description = "Public IP address of instance"
  value       = aws_instance.selfheal_ec2.public_ip
}

output "instance_state" {
  description = "Current state of instance"
  value       = aws_instance.selfheal_ec2.instance_state
}
