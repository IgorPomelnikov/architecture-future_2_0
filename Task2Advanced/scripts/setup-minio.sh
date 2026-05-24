#!/usr/bin/env bash
# Creates the Terraform state bucket in MinIO.
# Prerequisites: MinIO running (docker compose -f docker-compose.minio.yml up -d)

set -euo pipefail

ENDPOINT="${TF_STATE_ENDPOINT:-http://127.0.0.1:9000}"
ACCESS_KEY="${AWS_ACCESS_KEY_ID:-minioadmin}"
SECRET_KEY="${AWS_SECRET_ACCESS_KEY:-minioadmin}"
BUCKET="${TF_STATE_BUCKET:-terraform-state}"

if command -v mc >/dev/null 2>&1; then
  MC=mc
else
  echo "MinIO client (mc) not found. Install: https://min.io/docs/minio/linux/reference/minio-mc.html"
  exit 1
fi

"$MC" alias set task2 "$ENDPOINT" "$ACCESS_KEY" "$SECRET_KEY"
"$MC" mb "task2/${BUCKET}" --ignore-existing
echo "Bucket ready: ${BUCKET} at ${ENDPOINT}"
