#!/usr/bin/env bash
set -euo pipefail

KEY_FILE="environments/production/key.txt"
SECRETS_TEMPLATE="secrets/secrets.template.yaml"
SECRETS_ENCRYPTED="secrets/secrets.enc.yaml"

# 1. Apply Terraform infrastructure
echo "🚀 Applying Terraform infrastructure..."
cd environments/production
terraform apply -auto-approve

# 2. Encrypt secrets
cd ../../
echo "🔐 Encrypting secrets..."
SOPS_AGE_KEY_FILE="$KEY_FILE" sops --encrypt "$SECRETS_TEMPLATE" > "$SECRETS_ENCRYPTED"

# 3. Commit and push updated encrypted secrets
echo "📦 Committing encrypted secrets..."
git add .sops.yaml secrets/secrets.enc.yaml 
git commit -m "Automated: encrypted secrets after age key generation"
git push

echo "✅ Done: Terraform redeploy and secrets encryption complete!"
