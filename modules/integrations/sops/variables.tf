variable "age_private_key" {
  description = "Age private key from the age module"
  type        = string
  sensitive   = true
}

variable "age_public_key" {
  description = "Age public key from the age module"
  type        = string
}

variable "secrets_file" {
  description = "Path to the SOPS-encrypted secrets file"
  type        = string
}
