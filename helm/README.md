# KodeCD Helm Charts

> Kubernetes deployment for KodeCD using Helm

## Overview

This directory contains Helm charts for deploying KodeCD to Kubernetes clusters. The chart supports multiple deployment scenarios from local development to production-grade installations on major cloud providers.

## Quick Start

### Prerequisites

- Kubernetes 1.23+
- Helm 3.0+
- kubectl configured to access your cluster

### Install in 3 Steps

```bash
# 1. Create namespace
kubectl create namespace kodecd

# 2. Generate secrets
export SECRET_KEY_BASE=$(openssl rand -hex 64)
export RUNNER_TOKEN=$(openssl rand -hex 32)

# 3. Install
helm install kodecd ./kodecd \
  --namespace kodecd \
  --set secrets.secretKeyBase=$SECRET_KEY_BASE \
  --set secrets.runnerToken=$RUNNER_TOKEN
```

Access via port-forward:
```bash
kubectl port-forward -n kodecd svc/kodecd-web 8080:80
# Open http://localhost:8080
```

## Chart Structure

```
helm/
└── kodecd/
    ├── Chart.yaml              # Chart metadata
    ├── values.yaml             # Default values
    ├── values-production.yaml  # Production configuration
    ├── values-dev.yaml         # Development configuration
    ├── README.md               # Full documentation
    ├── QUICK_START.md          # Quick start guide
    └── templates/              # Kubernetes manifests
        ├── deployment-web.yaml
        ├── deployment-sidekiq.yaml
        ├── deployment-runner.yaml
        ├── service.yaml
        ├── ingress.yaml
        └── ...
```

## Configuration Examples

### Development

For local development or testing:

```bash
helm install kodecd ./kodecd \
  --namespace kodecd \
  -f ./kodecd/values-dev.yaml \
  --set secrets.secretKeyBase=$SECRET_KEY_BASE \
  --set secrets.runnerToken=$RUNNER_TOKEN
```

### Production with Custom Domain

```bash
helm install kodecd ./kodecd \
  --namespace kodecd \
  --set global.domain=kodecd.example.com \
  --set global.protocol=https \
  --set secrets.secretKeyBase=$SECRET_KEY_BASE \
  --set secrets.runnerToken=$RUNNER_TOKEN \
  --set ingress.enabled=true \
  --set ingress.className=nginx
```

### Production with values file

Create `my-values.yaml`:

```yaml
global:
  domain: kodecd.example.com
  protocol: https

secrets:
  secretKeyBase: "your-secret-key-base"
  runnerToken: "your-runner-token"

postgresql:
  auth:
    password: "secure-db-password"

redis:
  auth:
    password: "secure-redis-password"

web:
  replicaCount: 3
  autoscaling:
    enabled: true
    maxReplicas: 10

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
```

Install:
```bash
helm install kodecd ./kodecd -f my-values.yaml --namespace kodecd
```

## Using External Database/Redis

To use external PostgreSQL and Redis:

```yaml
postgresql:
  enabled: false
  external:
    host: postgres.example.com
    port: 5432
    username: kodecd
    password: "password"
    database: kodecd_production

redis:
  enabled: false
  external:
    host: redis.example.com
    port: 6379
    password: "password"
```

## Cloud Provider Examples

### AWS EKS

```yaml
persistence:
  storageClass: gp3

ingress:
  className: alb
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT:role/kodecd-role
```

### GCP GKE

```yaml
persistence:
  storageClass: pd-ssd

ingress:
  className: gce
  annotations:
    kubernetes.io/ingress.global-static-ip-name: kodecd-ip
    networking.gke.io/managed-certificates: kodecd-cert

serviceAccount:
  annotations:
    iam.gke.io/gcp-service-account: kodecd@project.iam.gserviceaccount.com
```

### Azure AKS

```yaml
persistence:
  storageClass: managed-premium

ingress:
  className: azure-application-gateway
  annotations:
    appgw.ingress.kubernetes.io/ssl-redirect: "true"
```

## Management Commands

### Check deployment
```bash
kubectl get pods -n kodecd
helm status kodecd -n kodecd
```

### View logs
```bash
kubectl logs -n kodecd -l app.kubernetes.io/component=web -f
kubectl logs -n kodecd -l app.kubernetes.io/component=sidekiq -f
```

### Rails console
```bash
kubectl exec -it -n kodecd deployment/kodecd-web -- bundle exec rails console
```

### Upgrade
```bash
helm upgrade kodecd ./kodecd -f my-values.yaml --namespace kodecd
```

### Rollback
```bash
helm rollback kodecd -n kodecd
```

### Uninstall
```bash
helm uninstall kodecd -n kodecd
kubectl delete pvc -n kodecd -l app.kubernetes.io/instance=kodecd
```

## Documentation

- [Full Documentation](kodecd/README.md) - Complete guide with all options
- [Quick Start Guide](kodecd/QUICK_START.md) - Get started quickly
- [Chart Reference](kodecd/values.yaml) - All configuration options
- [Production Setup](kodecd/values-production.yaml) - Production example

## Features

- **Auto-scaling**: HPA for web and sidekiq components
- **High Availability**: Multiple replicas with anti-affinity
- **Storage**: Persistent volumes for git, artifacts, cache
- **Security**: Pod security contexts, RBAC, network policies
- **Monitoring**: Health checks, readiness/liveness probes
- **Cloud Native**: Works with EKS, GKE, AKS, and other K8s distributions
- **Flexible**: Built-in or external PostgreSQL/Redis
- **GitOps Ready**: Declarative configuration with values files

## Support

- [GitHub Issues](https://github.com/yourusername/kodecd/issues)
- [Documentation](https://docs.kodecd.com)
- Email: support@kodecd.com

## License

See LICENSE file in the repository root.
