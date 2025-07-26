module "swarm" {
  source = "../../modules/cloud/aws/compute/swarm"
}

# Import the EC2 instance
import {
  to = module.swarm.aws_instance.docker-swarm-manager
  id = "i-085909aee7aba67e1"
}

# Import the Security Group
import {
  to = module.swarm.aws_security_group.docker-swarm-sg
  id = "sg-01eb2769e0afccbbd"
}
