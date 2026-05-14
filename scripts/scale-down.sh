#!/usr/bin/env bash
set -euo pipefail
export TF_VAR_hcloud_token="${CREAGEN_HCLOUD_TOKEN}"
export AWS_ACCESS_KEY_ID="${REMOTE_STATE_AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${REMOTE_STATE_AWS_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="us-east-1"

REPO_URL="git@github.com:YOUR_ORG/terraform-kubernetes.git"
WORKDIR="/tmp/terraform-kubernetes"
TF_DIR="$WORKDIR/terraform"
MIN_NODES=3

rm -rf "$WORKDIR"

git clone "$REPO_URL" "$WORKDIR"

cd "$TF_DIR"

CURRENT_COUNT=$(jq -r '.worker_count' worker_count.auto.tfvars.json)

if [ "$CURRENT_COUNT" -le "$MIN_NODES" ]; then
  echo "Already at minimum nodes"
  exit 0
fi

NODE_TO_REMOVE="creagen-worker-${CURRENT_COUNT}"

kubectl cordon "$NODE_TO_REMOVE"

kubectl drain "$NODE_TO_REMOVE"   --ignore-daemonsets   --delete-emptydir-data   --timeout=10m

NEW_COUNT=$((CURRENT_COUNT - 1))

jq --argjson count "$NEW_COUNT"   '.worker_count = $count'   worker_count.auto.tfvars.json > tmp.json

mv tmp.json worker_count.auto.tfvars.json

git add worker_count.auto.tfvars.json
git commit -m "autoscale: scale down workers ${CURRENT_COUNT} -> ${NEW_COUNT}"
git push

terraform init
terraform plan -out=tfplan

terraform show -no-color tfplan | grep "$NODE_TO_REMOVE"

terraform apply -auto-approve tfplan
