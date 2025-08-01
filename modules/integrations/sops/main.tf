
terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "1.2.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
}

resource "local_file" "sops_config" {
  content  = <<-EOT
    creation_rules:
      - path_regex: secrets/.*$
        key_groups:
          - age:
            - ${var.age_public_key}
  EOT
  filename = "${path.root}/../../.sops.yaml"
}
