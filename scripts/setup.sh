#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Bootstrapping Mini Cloud Platform..."

# Ensure we run from repo root (script may be invoked from elsewhere)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "▶ Ensuring required CLIs are installed..."
for cmd in kubectl terraform docker; do
	if ! command -v $cmd >/dev/null 2>&1; then
		echo "❌ Required tool missing: $cmd"
		exit 1
	fi
done

# WSL / Docker Desktop kubeconfig compatibility
echo "▶ Ensuring kubeconfig uses localhost (WSL compatibility)..."
KCFG="$HOME/.kube/config"
if [ -f "$KCFG" ] && grep -q "kubernetes.docker.internal" "$KCFG"; then
	sed -i 's|kubernetes.docker.internal|127.0.0.1|g' "$KCFG"
	echo "✔ kubeconfig patched to 127.0.0.1"
fi

# Kubectl apply wrapper to disable server-side validation during bootstrap
KUBECTL_APPLY_CMD=(kubectl apply --validate=false -f)

echo "▶ Starting LocalStack..."
# prefer modern 'docker compose' but fall back to 'docker-compose'
if command -v docker >/dev/null 2>&1; then
	if docker compose version >/dev/null 2>&1; then
		DOCKER_COMPOSE_CMD=(docker compose)
	elif command -v docker-compose >/dev/null 2>&1; then
		DOCKER_COMPOSE_CMD=(docker-compose)
	else
		echo "❌ docker compose or docker-compose not found. Please install Docker."
		exit 1
	fi
else
	echo "❌ docker not found. Please install Docker."
	exit 1
fi

if [ -d "localstack" ]; then
	(cd localstack && "${DOCKER_COMPOSE_CMD[@]}" up -d)
else
	echo "⚠️  localstack directory not found — skipping LocalStack start"
fi

echo "▶ Creating namespaces..."
"${KUBECTL_APPLY_CMD[@]}" kubernetes/base/

echo "▶ Installing Ingress controller..."
INGRESS_FILE="kubernetes/ingress-controller/install.yaml"
if [ -s "$INGRESS_FILE" ]; then
	"${KUBECTL_APPLY_CMD[@]}" "$INGRESS_FILE"
else
    echo "⚠️  Local ingress manifest missing or empty — applying upstream ingress-nginx controller"
	"${KUBECTL_APPLY_CMD[@]}" https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
fi

# Optional hardening: remind Windows users to add hosts entry so `api.local` resolves
echo "⚠️  Ensure Windows hosts file contains:"
echo "    127.0.0.1 api.local"

# Show ingress health/status so users see whether the ingress rule is present
echo "▶ Checking ingress health..."
# don't fail the script if the ingress isn't ready yet
kubectl get ingress -n backend || true

echo "▶ Deploying PostgreSQL..."
"${KUBECTL_APPLY_CMD[@]}" kubernetes/database/

# Wait for Postgres to be available before starting backend
echo "▶ Waiting for PostgreSQL to be ready..."
kubectl rollout status deployment/postgres -n data --timeout=120s || true

echo "▶ Deploying backend configuration..."
"${KUBECTL_APPLY_CMD[@]}" kubernetes/backend/configmap.yaml
"${KUBECTL_APPLY_CMD[@]}" kubernetes/backend/secret.yaml

echo "▶ Deploying backend service..."
"${KUBECTL_APPLY_CMD[@]}" kubernetes/backend/api-deployment.yaml
"${KUBECTL_APPLY_CMD[@]}" kubernetes/backend/api-service.yaml
"${KUBECTL_APPLY_CMD[@]}" kubernetes/backend/api-ingress.yaml
"${KUBECTL_APPLY_CMD[@]}" kubernetes/backend/hpa.yaml

# Phase 11: build frontend image if sources exist so users don't forget
if [ -d "frontend/web" ]; then
	echo "▶ Building frontend Docker image..."
	docker build -t mini-cloud-frontend:latest frontend/web
else
	echo "⚠️  frontend/web not found — skipping frontend image build"
fi

echo "▶ Provisioning cloud services (S3, SQS)..."
if [ -d "infrastructure/terraform" ]; then
	cd infrastructure/terraform
	terraform init -input=false -upgrade
	terraform apply -auto-approve

	echo "▶ Fetching cloud outputs..."

	S3_BUCKET=$(terraform output -raw s3_bucket_name)
	SQS_URL=$(terraform output -raw sqs_queue_url)

	echo "▶ Creating cloud config..."

	sed -e "s|__S3_BUCKET__|$S3_BUCKET|g" \
	    -e "s|__SQS_URL__|$SQS_URL|g" \
	    "$REPO_ROOT/kubernetes/backend/cloud-config.yaml.template" \
	    > "$REPO_ROOT/kubernetes/backend/cloud-config.yaml"

	kubectl apply -f "$REPO_ROOT/kubernetes/backend/cloud-config.yaml"
	cd "$REPO_ROOT"
else
	echo "⚠️  infrastructure/terraform not found — skipping Terraform provisioning"
fi

echo "✅ Mini cloud is ready!"
echo "API: http://api.local"


