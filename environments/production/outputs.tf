# Output the SSH command to connect to the instance
output "swarm_ssh_commands" {
  value       = module.swarm.ssh_commands
  description = "The SSH commands to connect to the instances."
}

output "age_key_public" {
  value = module.age_keys.age_public_key
}

output "age_key_secret" {
  value = module.age_keys.age_secret_key
  sensitive = true
}

