#!/usr/bin/env bash
# in scripts/asdf_plugins.sh
# install necessary plugins

# Set up environment variables for PostgreSQL installation
export PKG_CONFIG_PATH="/opt/homebrew/opt/icu4c/lib/pkgconfig:$PKG_CONFIG_PATH"
export LDFLAGS="-L/opt/homebrew/opt/icu4c/lib"
export CPPFLAGS="-I/opt/homebrew/opt/icu4c/include"
plugins=(
  "github-cli"
  "packer"
  "terraform"
  # Not available on asdf for apple silicon, install manually via brew
  # "awscli" 
  "elixir"
  "erlang"
  "postgres"
  "jq"
  "age"
  "sops"
)
for plugin in "${plugins[@]}"; do
  asdf plugin add "$plugin" || true
  # the "|| true" ignore errors if a certain plugin already exists
  asdf install "$plugin" latest || true
  # install the latest version of each plugin
done
echo "Installation complete."
echo "Please restart your terminal or source your profile file."
brew install awscli
