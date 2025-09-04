#!/usr/bin/env bash
set -euo pipefail
KEY_DIR="var/lib/sops-nix/keys/age"
KEY_PATH="$KEY_DIR/keys.txt"
if [ ! -f "$KEY_PATH" ]; then
  echo "Generating Age key at /$KEY_PATH ..."
  sudo mkdir -p "/$KEY_DIR"
  age-keygen | sudo tee "/$KEY_PATH" >/dev/null
  sudo chmod 600 "/$KEY_PATH"
fi
echo "Age public key:"
sudo sed -n 's/^# public key: //p' "/$KEY_PATH"
if [ ! -f secrets/sops/secrets.sops.yaml ]; then
  mkdir -p secrets/sops
  cat > secrets/sops/secrets.sops.yaml <<'EOF'
sops: PLACEHOLDER
RESTIC_PASSWORD: "changeme"
B2_ACCOUNT_ID: "xxx"
B2_ACCOUNT_KEY: "xxx"
TAILSCALE_AUTHKEY: "tskey-xxx"
MOTHERDUCK_TOKEN: ""
GITHUB_TOKEN: ""
GHCR_USER: ""
GHCR_TOKEN: ""
EOF
fi
echo "Encrypt with:  sops -e -i secrets/sops/secrets.sops.yaml"
