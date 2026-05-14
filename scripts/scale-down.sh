#!/usr/bin/env bash
set -euo pipefail
export TF_VAR_hcloud_token="${HCLOUD_TOKEN}"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="us-east-1"

REPO_URL="git@github.com:mdv-devops/creagen-kubernetes-cluster.git"
WORKDIR="/tmp/terraform-kubernetes"
TF_DIR="$WORKDIR/terraform"
MIN_NODES=3

rm -rf "$WORKDIR"

mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

git clone "$REPO_URL" "$WORKDIR"

cd "$TF_DIR"

git config user.name "jenkins-autoscaler"
git config user.email "jenkins-autoscaler@medevelop.studio"

CURRENT_COUNT=$(jq -r '.worker_count' worker_count.auto.tfvars.json)

if [ "$CURRENT_COUNT" -le "$MIN_NODES" ]; then
  echo "Already at minimum nodes"
  exit 0
fi

NODE_TO_REMOVE="creagen-worker-${CURRENT_COUNT}"

kubectl cordon "$NODE_TO_REMOVE"

kubectl drain "$NODE_TO_REMOVE" \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --timeout=10m

DRAIN_SETTLE_SECONDS=120

echo "Waiting ${DRAIN_SETTLE_SECONDS}s after drain..."
sleep "$DRAIN_SETTLE_SECONDS"

NEW_COUNT=$((CURRENT_COUNT - 1))

jq --argjson count "$NEW_COUNT"   '.worker_count = $count'   worker_count.auto.tfvars.json > tmp.json

mv tmp.json worker_count.auto.tfvars.json

terraform init
terraform plan -out=tfplan

terraform show tfplan | grep "$NODE_TO_REMOVE"

terraform apply -auto-approve tfplan

git add worker_count.auto.tfvars.json
git commit -m "autoscale: scale down workers ${CURRENT_COUNT} -> ${NEW_COUNT}"
git push
