output "age_secret_key" {
  description = "Secret Age key"
  value       = age_secret_key.this.secret_key
  sensitive   = true
}

output "age_public_key" {
  description = "Public Age key"
  value       = age_secret_key.this.public_key
}
