#!/usr/bin/env bash
set -euo pipefail
export TF_VAR_hcloud_token="${HCLOUD_TOKEN}"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="us-east-1"

REPO_URL="git@github.com:mdv-devops/creagen-kubernetes-cluster.git"
WORKDIR="/tmp/terraform-kubernetes"
TF_DIR="$WORKDIR/terraform"
MAX_NODES=10

rm -rf "$WORKDIR"

mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

git clone "$REPO_URL" "$WORKDIR"

cd "$TF_DIR"

git config user.name "jenkins-autoscaler"
git config user.email "jenkins-autoscaler@medevelop.studio"

CURRENT_COUNT=$(jq -r '.worker_count' worker_count.auto.tfvars.json)

if [ "$CURRENT_COUNT" -ge "$MAX_NODES" ]; then
  echo "Already at max nodes"
  exit 0
fi

NEW_COUNT=$((CURRENT_COUNT + 1))

jq --argjson count "$NEW_COUNT"   '.worker_count = $count'   worker_count.auto.tfvars.json > tmp.json

mv tmp.json worker_count.auto.tfvars.json

terraform init
terraform plan -out=tfplan

terraform show tfplan

terraform apply -auto-approve tfplan

EXPECTED_NODE="creagen-worker-${NEW_COUNT}"

echo "Waiting for Kubernetes node object: ${EXPECTED_NODE}"

timeout 900 bash -c '
  until kubectl get node "'"${EXPECTED_NODE}"'" >/dev/null 2>&1; do
    echo "Node '"${EXPECTED_NODE}"' not found yet. Waiting..."
    sleep 15
  done
'

echo "Node ${EXPECTED_NODE} exists. Waiting for Ready condition..."

kubectl wait \
  --for=condition=Ready \
  "node/${EXPECTED_NODE}" \
  --timeout=15m

echo "Node ${EXPECTED_NODE} is Ready. Waiting 60s for cluster components..."
sleep 60

echo "Scale up completed"

git add worker_count.auto.tfvars.json
git commit -m "autoscale: scale up workers ${CURRENT_COUNT} -> ${NEW_COUNT}"
git push
