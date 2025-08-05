output "instance_public_ip" {
  value       = aws_instance.docker-swarm-node[0].public_ip
  description = "The public IP address of the first instance."
}

output "private_key" {
  value       = local_sensitive_file.private_key.content
  sensitive   = true
  description = "The SSH private key to connect to the instance."
}

output "ssh_commands" {
  value = {
    for idx, instance in aws_instance.docker-swarm-node :
    format("node_%d", idx + 1) =>
    format("ssh -i ./private_key.pem ec2-user@%s", instance.public_ip)
  }
  description = "The SSH commands to connect to the instances."
}
