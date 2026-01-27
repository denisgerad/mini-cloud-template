# Mini Cloud Platform – Local Installation Guide

This project bootstraps a full cloud-native environment locally using:

- Docker Desktop
- Kubernetes
- LocalStack (S3 + SQS)
- Terraform
- FastAPI backend
- NGINX Ingress

It is designed to be installed with **one command**:

```bash
./scripts/setup.sh
System Requirements
OS
Windows 11 + WSL2 (Ubuntu)

Software
Docker Desktop (latest)
Kubernetes enabled
kubectl
terraform
awscli
git

One-time host setup
1. Enable Kubernetes in Docker Desktop
Docker Desktop → Settings → Kubernetes → Enable → Apply

Wait until status shows:

Kubernetes is running
2. Windows hosts file
Open as Administrator:

C:\Windows\System32\drivers\etc\hosts
Add:
127.0.0.1 api.local
Save.

3. Verify kubectl works
In WSL:
kubectl get nodes

Expected:
docker-desktop   Ready
Installation

Step 1 – Clone
git clone <repo-url>
cd mini-cloud

Step 2 – Ensure no old LocalStack is running
docker ps | grep localstack

If found:
docker stop localstack-localstack-1
docker rm localstack-localstack-1

Step 3 – Run installer
chmod +x scripts/setup.sh
./scripts/setup.sh

Expected final output:
Mini cloud is ready!
API: http://api.local

Step 4 – Test
Open browser:
http://api.local
Expected JSON response.

Architecture Overview
Browser
   |
Ingress (NGINX)
   |
API Service (FastAPI, autoscaled)
   |
PostgreSQL

+ S3 (LocalStack)
+ SQS (LocalStack)
+ Terraform provisioning

Common Problems & Fixes
❌ api.local shows nginx 404
Cause:
Missing ingressClassName
Missing Windows hosts entry

Fix:
kubectl get ingress -n backend

Ensure ingressClassName is set:
spec:
  ingressClassName: nginx

Verify Windows hosts file contains:
127.0.0.1 api.local

Restart ingress:
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx

❌ kubectl cannot connect / kubernetes.docker.internal error
Fix kubeconfig:
nano ~/.kube/config

Change:
server: https://kubernetes.docker.internal:6443

to:

server: https://127.0.0.1:6443

Then:
kubectl get nodes

❌ Terraform cannot download provider
Fix DNS in WSL:
sudo nano /etc/wsl.conf

Add:
[network]
generateResolvConf = false

Then:
sudo rm /etc/resolv.conf
sudo nano /etc/resolv.conf

Add:
nameserver 8.8.8.8
nameserver 1.1.1.1

Restart WSL:
wsl --shutdown

❌ Terraform: cannot connect to LocalStack
Ensure LocalStack is running:
docker ps | grep localstack

Check health:
curl http://localhost:4566/_localstack/health

❌ Port 4566 already in use
Another LocalStack is running:
docker stop localstack-localstack-1
docker rm localstack-localstack-1
Re-run setup.

Reset everything (clean reinstall)
kubectl delete namespaces frontend backend data
docker rm -f localstack-localstack-1
cd infrastructure/terraform
terraform destroy -auto-approve
Then rerun setup.

Useful commands
kubectl get pods -A
kubectl get ingress -A
kubectl get svc -A
docker ps
Project goals
Learn Kubernetes orchestration
Learn cloud networking & ingress
Learn S3 + SQS architecture
Learn autoscaling
Learn Terraform
Learn platform engineering patterns

Next phases
Frontend deployment (React)
Worker services
Monitoring (Prometheus/Grafana)
CI/CD
HTTPS
IAM simulation

---

# Final recommendation
For your clone test:
1. Stop & remove LocalStack
2. Clone project
3. Run setup.sh
4. Verify api.local

---