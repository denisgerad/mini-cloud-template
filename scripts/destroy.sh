#!/bin/bash

echo "Destroying platform..."

kubectl delete namespaces frontend backend data
cd infrastructure/terraform && terraform destroy -auto-approve
cd ../..

docker compose -f localstack/docker-compose.yml down
