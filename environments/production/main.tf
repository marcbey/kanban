module "swarm" {
  source = "../../modules/cloud/aws/compute/swarm"
  private_key_path = "${path.module}/private_key.pem"
}

# Import the EC2 instance
# import {
#   to = module.swarm.aws_instance.docker-swarm-manager
#   id = "i-085909aee7aba67e1"
# }

# Import the Security Group
# import {
#   to = module.swarm.aws_security_group.docker-swarm-sg
#   id = "sg-01eb2769e0afccbbd"
# }

# Import the Key Pair
# import {
#   to = module.swarm.aws_key_pair.deployer_key
#   id = "swarm-key"
# }

# Output the SSH command to connect to the instance
output "swarm_ssh_command" {
  value       = module.swarm.ssh_command
  description = "The SSH command to connect to the instance."
}
