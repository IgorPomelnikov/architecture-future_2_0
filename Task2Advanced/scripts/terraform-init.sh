#!/usr/bin/env bash
# Initialize Terraform/OpenTofu with remote S3 backend for a given environment.
# Usage: ./scripts/terraform-init.sh dev

set -euo pipefail

ENV="${1:?Usage: $0 <dev|stage|prod>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_DIR="${ROOT}/envs/${ENV}"
BACKEND_FILE="${ENV_DIR}/backend.hcl"

if [[ ! -f "$BACKEND_FILE" ]]; then
  echo "Missing ${BACKEND_FILE}"
  echo "Copy: cp ${ENV_DIR}/backend.hcl.example ${BACKEND_FILE}"
  exit 1
fi

CLI="${TF_CLI:-tofu}"
if ! command -v "$CLI" >/dev/null 2>&1; then
  CLI=terraform
fi

cd "$ENV_DIR"
"$CLI" init -input=false -backend-config=backend.hcl -reconfigure
echo "Initialized ${ENV} with remote backend."
