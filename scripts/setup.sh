#!/bin/bash
set -e

echo "🚀 Bootstrapping Mini Cloud Platform..."

echo "▶ Starting LocalStack..."
cd localstack
docker compose up -d
cd ..

echo "▶ Creating namespaces..."
kubectl apply -f kubernetes/base/

echo "▶ Installing Ingress controller..."
INGRESS_FILE="kubernetes/ingress-controller/install.yaml"
if [ -s "$INGRESS_FILE" ]; then
	kubectl apply -f "$INGRESS_FILE"
else
	echo "⚠️  Local ingress manifest is empty — applying upstream ingress-nginx controller"
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
fi

# Optional hardening: remind Windows users to add hosts entry so `api.local` resolves
echo "⚠️  Ensure Windows hosts file contains:"
echo "    127.0.0.1 api.local"

# Show ingress health/status so users see whether the ingress rule is present
echo "▶ Checking ingress health..."
# don't fail the script if the ingress isn't ready yet
kubectl get ingress -n backend || true

echo "▶ Deploying PostgreSQL..."
kubectl apply -f kubernetes/database/

echo "▶ Deploying backend configuration..."
kubectl apply -f kubernetes/backend/configmap.yaml
kubectl apply -f kubernetes/backend/secret.yaml

echo "▶ Deploying backend service..."
kubectl apply -f kubernetes/backend/api-deployment.yaml
kubectl apply -f kubernetes/backend/api-service.yaml
kubectl apply -f kubernetes/backend/api-ingress.yaml
kubectl apply -f kubernetes/backend/hpa.yaml

echo "▶ Provisioning cloud services (S3, SQS)..."
cd infrastructure/terraform
terraform init -input=false
terraform apply -auto-approve
cd ../..

echo "✅ Mini cloud is ready!"
echo "API: http://api.local"
