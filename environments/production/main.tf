module "swarm" {
  source = "../../modules/cloud/aws/compute/swarm"

  private_key_path = "${path.module}/private_key.pem"
  account_id       = var.account_id
}

module "repository_secrets" {
  source = "../../modules/integrations/github/secrets"

  secrets = {
    "PRIVATE_KEY"           = module.swarm.private_key,
    "AWS_ACCESS_KEY_ID"     = var.aws_access_key_id,
    "AWS_SECRET_ACCESS_KEY" = var.aws_secret_access_key,
    "AGE_KEY"               = module.age_keys.age_secret_key,
    "GH_PAT"                = var.gh_pat
  }
  repository   = "kanban"
  github_owner = "marcbey"
}

module "contributing_workflow" {
  source = "../../modules/integrations/github/contributing_workflow"

  repository   = "kanban"
  github_owner = "marcbey"
  status_checks = [
    "Compile with mix test, format, dialyzer & unused deps check"
  ]
}

# Import the EC2 instance
# import {
#   to = module.swarm.aws_instance.docker-swarm-node
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

# import {
#   to = module.swarm.aws_ssm_parameter.swarm_token
#   id = "/docker/swarm_manager_token"
# }

module "age_keys" {
  source = "../../modules/integrations/age"

  output_key_path = "${path.module}/key.txt"
}

module "sops_integration" {
  source = "../../modules/integrations/sops"

  age_private_key = module.age_keys.age_secret_key
  age_public_key  = module.age_keys.age_public_key
  secrets_file    = "${path.module}/../../secrets/secrets.enc.yaml"
}
