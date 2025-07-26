output "ssh_command" {
  value       = "ssh -i ${var.private_key_path} ec2-user@${aws_instance.docker-swarm-manager.public_ip}"
  description = "The SSH command to connect to the instance."
}

output "instance_public_ip" {
  value       = aws_instance.docker-swarm-manager.public_ip
  description = "The public IP address of the instance."
} 