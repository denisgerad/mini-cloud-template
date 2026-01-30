Mini Cloud Platform — Phases 1 to 11

A local, production-style cloud-native platform built on Docker Desktop + Kubernetes + Terraform + LocalStack, culminating in a full-stack React + API + PostgreSQL application exposed via an Ingress (load balancer).

This project is designed to help developers understand how real cloud platforms work, end to end, without needing an actual AWS account.

🚀 What This Project Achieves
By completing Phases 1 → 11, you have built:
A local Kubernetes-based cloud platform
Infrastructure as Code using Terraform
Simulated AWS services (S3, SQS) via LocalStack
A backend API deployed as containers
A PostgreSQL database running inside Kubernetes
A React frontend served via NGINX
Ingress-based routing similar to AWS ALB
Fully decoupled application and infrastructure

This mirrors real-world cloud architecture used in AWS, GCP, and Azure.

🧠 High-Level Architecture
┌───────────────────────────┐
│        User Browser       │
└─────────────┬─────────────┘
              │
      ┌───────▼────────┐
      │ Ingress (NGINX)│   ← Load Balancer (like AWS ALB)
      └───────┬────────┘
              │
     ┌────────┴──────────┐
     │                   │
┌────▼─────┐        ┌────▼─────┐
│ app.local│        │ api.local│
│ React UI │        │ API Pod  │
│ (NGINX)  │        │ (FastAPI │
└────┬─────┘        │  /Django)│
     │              └────┬─────┘
     │                   │
     │           ┌───────▼────────┐
     │           │ PostgreSQL DB  │
     │           │ (K8s Stateful) │
     │           └────────────────┘
     │
     │
     │   ┌────────────────────────────┐
     │   │ LocalStack (AWS Simulator) │
     │   │  - S3 Bucket               │
     │   │  - SQS Queue               │

     Mini Cloud Platform — Phases 1 to 11

     A local, production-style cloud-native platform built on Docker Desktop + Kubernetes + Terraform + LocalStack, culminating in a full-stack React + API + PostgreSQL application exposed via an Ingress (load balancer).

     This project is designed to help developers understand how real cloud platforms work, end to end, without needing an actual AWS account.

     🚀 What This Project Achieves
     By completing Phases 1 → 11, you have built:
     - A local Kubernetes-based cloud platform
     - Infrastructure as Code using Terraform
     - Simulated AWS services (S3, SQS) via LocalStack
     - A backend API deployed as containers
     - A PostgreSQL database running inside Kubernetes
     - A React frontend served via NGINX
     - Ingress-based routing similar to AWS ALB
     - Fully decoupled application and infrastructure

     This mirrors real-world cloud architecture used in AWS, GCP, and Azure.

     🧠 High-Level Architecture
     ``` 
     ┌───────────────────────────┐
     │        User Browser       │
     └─────────────┬─────────────┘
                   │
           ┌───────▼────────┐
           │ Ingress (NGINX)│   ← Load Balancer (like AWS ALB)
           └───────┬────────┘
                   │
          ┌────────┴──────────┐
          │                   │
     ┌────▼─────┐        ┌────▼─────┐
     │ app.local│        │ api.local│
     │ React UI │        │ API Pod  │
     │ (NGINX)  │        │ (FastAPI │
     └────┬─────┘        │  /Django)│
          │              └────┬─────┘
          │                   │
          │           ┌───────▼────────┐
          │           │ PostgreSQL DB  │
          │           │ (K8s Stateful) │
          │           └────────────────┘
          │
          │
          │   ┌────────────────────────────┐
          │   │ LocalStack (AWS Simulator) │
          │   │  - S3 Bucket               │
          │   │  - SQS Queue               │
          │   └────────────────────────────┘
     ```

     📦 Project Structure
     ``` 
     mini-cloud/
     ├── frontend/
     │   └── web/                  # React application
     │       ├── Dockerfile
     │       └── src/
     │
     ├── kubernetes/
     │   ├── base/                  # Namespaces
     │   ├── ingress-controller/    # NGINX ingress
     │   ├── database/              # PostgreSQL manifests
     │   ├── backend/               # API manifests
     │   └── frontend/              # React deployment, service, ingress
     │
     ├── infrastructure/
     │   └── terraform/             # S3, SQS (IaC)
     │
     ├── localstack/                # Docker Compose for LocalStack
     │
     ├── scripts/
     │   └── setup.sh               # One-command bootstrap
     │
     ├── README.md
     └── .gitignore
     ```

     🧩 Phases Overview
     | Phase | Description |
     |------:|:------------|
     | 1 | Docker Desktop + WSL setup |
     | 2 | Kubernetes tooling (kubectl, namespaces) |
     | 3 | Ingress controller (NGINX) |
     | 4 | LocalStack (AWS simulation) |
     | 5 | Terraform provisioning (S3, SQS) |
     | 6 | Backend API deployment |
     | 7 | Database (PostgreSQL) |
     | 8 | Ingress routing + DNS |
     | 9 | Scaling, health checks, secrets |
     | 10 | App decoupled from infrastructure |
     | 11 | React frontend deployment |

     🖥️ Environment Requirements
     Host System
     - Windows 11
     - 16 GB RAM
     - SSD recommended

     Software
     - Docker Desktop (with Kubernetes enabled)
     - WSL2 (Ubuntu 22.04 recommended)
     - Git

     WSL Tools
     ```bash
     sudo apt update
     sudo apt install -y \
       curl unzip git ca-certificates
     ```

     Install:
     - kubectl
     - terraform
     - docker-cli

     ▶️ Getting Started (Quick Start)
     1. Clone the repository
     ```bash
     git clone <your-repo-url>
     cd mini-cloud
     ```
     2. Start the entire platform
     ```bash
     chmod +x scripts/setup.sh
     ./scripts/setup.sh
     ```

     This will:
     - Start LocalStack
     - Create Kubernetes namespaces
     - Install ingress controller
     - Deploy database
     - Deploy API
     - Provision S3 + SQS
     - Inject cloud config
     - Deploy React frontend

     🌐 Access the Application
     Add to Windows hosts file:
     ```text
     127.0.0.1 api.local
     127.0.0.1 app.local
     ```

     Then open:
     - Frontend: http://app.local
     - API: http://api.local
     - API DB test: http://api.local/db

     🔧 Useful Commands
     Kubernetes
     ```bash
     kubectl get pods -A
     kubectl get svc -A
     kubectl get ingress -A
     kubectl logs -n backend deploy/api
     ```

     Terraform
     ```bash
     cd infrastructure/terraform
     terraform init
     terraform apply
     terraform output
     ```

     Docker
     ```bash
     docker ps
     docker images
     ```

     🧯 Troubleshooting
     - API not reachable from React: Ensure CORS is enabled in API; Check browser DevTools → Console
     - Ingress 404: Verify ingressClassName: nginx; Ensure hosts file entries exist
     - kubectl OpenAPI / DNS error (WSL): `sed -i 's/kubernetes.docker.internal/127.0.0.1/g' ~/.kube/config`
     - Database errors: Verify DB credentials match; Restart API after secret changes: `kubectl rollout restart deployment api -n backend`
     - Terraform provider errors: `terraform init -upgrade`

     🎯 Why This Project Matters
     This project demonstrates:
     - Cloud-native architecture
     - Kubernetes fundamentals
     - Infrastructure as Code
     - App ↔ Infra decoupling
     - Load balancing & routing
     - Real production debugging scenarios

     It directly maps to AWS EKS + ALB + RDS + S3 + SQS.

     📌 Next Phases (Optional)
     - Phase 12: CI/CD (GitHub Actions)
     - Phase 13: HTTPS (cert-manager)
     - Phase 14: Monitoring (Prometheus/Grafana)
     - Phase 15: Background workers (SQS)
     - Phase 16: Auth (JWT / OAuth)
     - Phase 17: Deploy to AWS EKS

     ✅ Status
     Mini Cloud Platform: COMPLETE (Phase 11)
     This repository can be used as:
     - A learning reference
     - A portfolio project
     - A cloud engineering starter template

     Happy building ☁️🚀

