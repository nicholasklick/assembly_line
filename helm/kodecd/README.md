# KodeCD Helm Chart

> Deploy KodeCD to Kubernetes using Helm

## Overview

This Helm chart deploys a complete KodeCD CI/CD platform on Kubernetes. It includes:

- **Web**: Rails application (Puma)
- **Sidekiq**: Background job processor
- **Runner**: CI/CD job executor
- **PostgreSQL**: Database (optional, can use external)
- **Redis**: Cache and queue (optional, can use external)

## Prerequisites

- Kubernetes 1.23+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure
- Ingress controller (nginx recommended)
- cert-manager (optional, for TLS)

## Quick Start

### 1. Add Helm Repository (if published)

```bash
helm repo add kodecd https://charts.kodecd.com
helm repo update
```

### 2. Create namespace

```bash
kubectl create namespace kodecd
```

### 3. Generate secrets

```bash
# Generate secret key base
SECRET_KEY_BASE=$(openssl rand -hex 64)

# Generate runner token
RUNNER_TOKEN=$(openssl rand -hex 32)
```

### 4. Install the chart

```bash
helm install kodecd ./helm/kodecd \
  --namespace kodecd \
  --set global.domain=kodecd.example.com \
  --set secrets.secretKeyBase=$SECRET_KEY_BASE \
  --set secrets.runnerToken=$RUNNER_TOKEN \
  --set postgresql.auth.password=$(openssl rand -hex 16) \
  --set redis.auth.password=$(openssl rand -hex 16)
```

## Configuration

### Basic Configuration

Create a `values.yaml` file:

```yaml
global:
  domain: kodecd.example.com
  protocol: https

secrets:
  secretKeyBase: "your-secret-key-base-here"
  runnerToken: "your-runner-token-here"

postgresql:
  auth:
    password: "secure-database-password"

redis:
  auth:
    password: "secure-redis-password"

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: kodecd.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: kodecd-tls
      hosts:
        - kodecd.example.com
```

Install with your custom values:

```bash
helm install kodecd ./helm/kodecd -f values.yaml --namespace kodecd
```

### Using External Database

To use an external PostgreSQL database:

```yaml
postgresql:
  enabled: false
  external:
    host: postgres.example.com
    port: 5432
    username: kodecd
    password: "your-password"
    database: kodecd_production
```

### Using External Redis

To use an external Redis instance:

```yaml
redis:
  enabled: false
  external:
    host: redis.example.com
    port: 6379
    password: "your-password"
```

### SMTP Configuration

Enable email notifications:

```yaml
config:
  smtp:
    enabled: true
    address: smtp.gmail.com
    port: 587
    username: notifications@example.com
    password: "your-smtp-password"
    domain: example.com
```

### Storage Configuration

Adjust persistent volume sizes:

```yaml
persistence:
  storageClass: "fast-ssd"
  gitData:
    size: 100Gi
  artifacts:
    size: 200Gi
  cache:
    size: 100Gi
  storage:
    size: 50Gi
  runnerCache:
    size: 100Gi
```

### Resource Limits

Configure resource requests and limits:

```yaml
web:
  replicaCount: 3
  resources:
    requests:
      cpu: 1000m
      memory: 2Gi
    limits:
      cpu: 4000m
      memory: 8Gi

sidekiq:
  replicaCount: 2
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 2000m
      memory: 4Gi
```

### Auto-scaling

Enable Horizontal Pod Autoscaler:

```yaml
web:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 80
    targetMemoryUtilizationPercentage: 80

sidekiq:
  autoscaling:
    enabled: true
    minReplicas: 1
    maxReplicas: 5
    targetCPUUtilizationPercentage: 80
```

## Installation Examples

### Development/Testing

Minimal setup for testing:

```bash
helm install kodecd ./helm/kodecd \
  --namespace kodecd \
  --set global.domain=localhost \
  --set global.protocol=http \
  --set secrets.secretKeyBase=$(openssl rand -hex 64) \
  --set secrets.runnerToken=$(openssl rand -hex 32) \
  --set ingress.enabled=false \
  --set service.type=NodePort \
  --set persistence.gitData.size=10Gi \
  --set persistence.artifacts.size=20Gi
```

### Production on AWS EKS

```yaml
# values-production.yaml
global:
  domain: kodecd.company.com
  protocol: https

web:
  replicaCount: 3
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10

persistence:
  storageClass: gp3
  gitData:
    size: 100Gi
  artifacts:
    size: 500Gi

ingress:
  enabled: true
  className: alb
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:...

nodeSelector:
  node.kubernetes.io/instance-type: m5.xlarge
```

### Production on GKE

```yaml
# values-gke.yaml
global:
  domain: kodecd.company.com
  protocol: https

persistence:
  storageClass: pd-ssd

ingress:
  enabled: true
  className: gce
  annotations:
    kubernetes.io/ingress.global-static-ip-name: kodecd-ip
    networking.gke.io/managed-certificates: kodecd-cert

serviceAccount:
  annotations:
    iam.gke.io/gcp-service-account: kodecd@project.iam.gserviceaccount.com
```

## Upgrading

### Upgrade the release

```bash
helm upgrade kodecd ./helm/kodecd \
  --namespace kodecd \
  -f values.yaml
```

### Run database migrations

Migrations run automatically via init containers, but you can run manually:

```bash
kubectl exec -it deployment/kodecd-web -n kodecd -- bundle exec rails db:migrate
```

### Rollback

```bash
helm rollback kodecd -n kodecd
```

## Monitoring

### Check deployment status

```bash
# All pods
kubectl get pods -n kodecd

# Specific components
kubectl get pods -n kodecd -l app.kubernetes.io/component=web
kubectl get pods -n kodecd -l app.kubernetes.io/component=sidekiq
kubectl get pods -n kodecd -l app.kubernetes.io/component=runner
```

### View logs

```bash
# Web logs
kubectl logs -n kodecd -l app.kubernetes.io/component=web -f

# Sidekiq logs
kubectl logs -n kodecd -l app.kubernetes.io/component=sidekiq -f

# Runner logs
kubectl logs -n kodecd -l app.kubernetes.io/component=runner -f
```

### Access Rails console

```bash
kubectl exec -it deployment/kodecd-web -n kodecd -- bundle exec rails console
```

### Database console

```bash
kubectl exec -it deployment/kodecd-postgresql -n kodecd -- psql -U kodecd
```

## Backup and Restore

### Backup PostgreSQL

```bash
kubectl exec -it deployment/kodecd-postgresql -n kodecd -- \
  pg_dump -U kodecd kodecd_production > backup.sql
```

### Backup Persistent Volumes

```bash
# Create backup job
kubectl create job --from=cronjob/backup-job backup-manual -n kodecd

# Or use Velero for full cluster backups
velero backup create kodecd-backup --include-namespaces kodecd
```

### Restore from backup

```bash
# Restore database
kubectl exec -i deployment/kodecd-postgresql -n kodecd -- \
  psql -U kodecd kodecd_production < backup.sql
```

## Uninstallation

```bash
# Delete the release
helm uninstall kodecd -n kodecd

# Delete persistent volumes (WARNING: This deletes all data!)
kubectl delete pvc -n kodecd -l app.kubernetes.io/instance=kodecd

# Delete namespace
kubectl delete namespace kodecd
```

## Troubleshooting

### Pods not starting

Check pod events:
```bash
kubectl describe pod <pod-name> -n kodecd
```

Check logs:
```bash
kubectl logs <pod-name> -n kodecd
```

### Database connection errors

Check PostgreSQL is running:
```bash
kubectl get pods -n kodecd -l app.kubernetes.io/name=postgresql
```

Test connection:
```bash
kubectl exec -it deployment/kodecd-web -n kodecd -- \
  bundle exec rails runner "puts ActiveRecord::Base.connection.active?"
```

### Runner not picking up jobs

Check runner logs:
```bash
kubectl logs -n kodecd -l app.kubernetes.io/component=runner
```

Verify runner token:
```bash
kubectl get secret kodecd-secret -n kodecd -o jsonpath='{.data.runner-token}' | base64 -d
```

### Ingress not working

Check ingress:
```bash
kubectl get ingress -n kodecd
kubectl describe ingress kodecd -n kodecd
```

Verify ingress controller is running:
```bash
kubectl get pods -n ingress-nginx
```

## Parameters

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.domain` | Domain for KodeCD | `kodecd.example.com` |
| `global.protocol` | Protocol (http or https) | `https` |

### Image Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | KodeCD image repository | `kodecd/kodecd` |
| `image.tag` | Image tag | Chart appVersion |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Web Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `web.replicaCount` | Number of web replicas | `2` |
| `web.resources.limits.cpu` | CPU limit | `2000m` |
| `web.resources.limits.memory` | Memory limit | `4Gi` |
| `web.autoscaling.enabled` | Enable HPA | `false` |

### Database Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgresql.enabled` | Use built-in PostgreSQL | `true` |
| `postgresql.auth.username` | Database username | `kodecd` |
| `postgresql.auth.password` | Database password | `""` |
| `postgresql.primary.persistence.size` | Database storage size | `20Gi` |

For a complete list of parameters, see `values.yaml`.

## Support

- Documentation: https://docs.kodecd.com
- GitHub Issues: https://github.com/nicholasklick/assembly_line/issues
- Email: support@kodecd.com

## License

See LICENSE file in the repository root.
