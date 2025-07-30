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

data "github_repository" "repo" {
  full_name = "${var.github_owner}/${var.repository}"
}

resource "github_branch_protection" "main" {
  repository_id  = data.github_repository.repo.node_id
  pattern        = "main"
  enforce_admins = true
  required_status_checks {
    strict   = true
    contexts = var.status_checks
  }
  required_pull_request_reviews {
    require_code_owner_reviews      = false
    required_approving_review_count = 1
  }
}
