terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}

provider "github" {
  owner = var.github_owner
}

resource "github_branch_protection" "main" {
  repository_id  = var.repository
  pattern        = "main"
  enforce_admins = true
  required_status_checks {
    strict   = true
    contexts = var.status_checks
  }
}
