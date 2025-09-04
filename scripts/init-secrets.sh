#!/usr/bin/env bash
set -euo pipefail

# Generate Age key for sops-nix, if not present
KEY_DIR="var/lib/sops-nix/keys/age"
KEY_PATH="$KEY_DIR/keys.txt"

if [ ! -f "$KEY_PATH" ]; then
	echo "Generating Age key at /$KEY_PATH ..."
	sudo mkdir -p "/$KEY_DIR"
	age-keygen | sudo tee "/$KEY_PATH" >/dev/null
	sudo chmod 600 "/$KEY_PATH"
fi

echo "Age key:"
sudo cat "/$KEY_PATH" | sed -n 's/^# public key: //p'

# Create placeholder sops file if missing
if [ ! -f secrets/sops/secrets.sops.yaml ]; then
	echo "Creating secrets/sops/secrets.sops.yaml (unencrypted placeholder)"
	mkdir -p secrets/sops
	cat >secrets/sops/secrets.sops.yaml <<'EOF'
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

echo "Now edit secrets/sops/secrets.sops.yaml and encrypt it with:"
echo "  sops -e -i secrets/sops/secrets.sops.yaml"
