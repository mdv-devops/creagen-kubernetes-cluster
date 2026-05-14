#!/usr/bin/env bash
set -euo pipefail
export TF_VAR_hcloud_token="${CREAGEN_HCLOUD_TOKEN}"
export AWS_ACCESS_KEY_ID="${REMOTE_STATE_AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${REMOTE_STATE_AWS_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="us-east-1"

REPO_URL="git@github.com:YOUR_ORG/terraform-kubernetes.git"
WORKDIR="/tmp/terraform-kubernetes"
TF_DIR="$WORKDIR/terraform"
MAX_NODES=10

rm -rf "$WORKDIR"

git clone "$REPO_URL" "$WORKDIR"

cd "$TF_DIR"

CURRENT_COUNT=$(jq -r '.worker_count' worker_count.auto.tfvars.json)

if [ "$CURRENT_COUNT" -ge "$MAX_NODES" ]; then
  echo "Already at max nodes"
  exit 0
fi

NEW_COUNT=$((CURRENT_COUNT + 1))

jq --argjson count "$NEW_COUNT"   '.worker_count = $count'   worker_count.auto.tfvars.json > tmp.json

mv tmp.json worker_count.auto.tfvars.json

git add worker_count.auto.tfvars.json
git commit -m "autoscale: scale up workers ${CURRENT_COUNT} -> ${NEW_COUNT}"
git push

terraform init
terraform apply -auto-approve

EXPECTED_NODE="creagen-worker-${NEW_COUNT}"

kubectl wait   --for=condition=Ready   "node/${EXPECTED_NODE}"   --timeout=15m
