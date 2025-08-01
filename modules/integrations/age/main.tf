terraform {
  required_providers {
    age = {
      source  = "clementblaise/age"
      version = "0.1.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
}

# Generate an Age key pair
resource "age_secret_key" "this" {}

# Write private key to environments/production/key.txt
resource "local_file" "private_key_file" {
  content  = age_secret_key.this.secret_key
  filename = var.output_key_path
}
