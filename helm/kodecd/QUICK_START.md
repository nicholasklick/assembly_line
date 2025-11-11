# KodeCD Helm Chart - Quick Start

> Get KodeCD running on Kubernetes in minutes

## Prerequisites

- Kubernetes cluster (1.23+)
- Helm 3.0+
- kubectl configured
- Ingress controller (optional, for external access)

## 1. Create Namespace

```bash
kubectl create namespace kodecd
```

## 2. Generate Secrets

```bash
# Generate secret key base
export SECRET_KEY_BASE=$(openssl rand -hex 64)

# Generate runner token
export RUNNER_TOKEN=$(openssl rand -hex 32)

# Generate database password
export DB_PASSWORD=$(openssl rand -hex 16)

# Generate Redis password
export REDIS_PASSWORD=$(openssl rand -hex 16)
```

## 3. Install KodeCD

### Option A: Quick Install (ClusterIP + Port Forward)

Perfect for testing or development:

```bash
helm install kodecd ./helm/kodecd \
  --namespace kodecd \
  --set global.domain=localhost \
  --set global.protocol=http \
  --set secrets.secretKeyBase=$SECRET_KEY_BASE \
  --set secrets.runnerToken=$RUNNER_TOKEN \
  --set postgresql.auth.password=$DB_PASSWORD \
  --set redis.auth.password=$REDIS_PASSWORD \
  --set ingress.enabled=false \
  --set service.type=ClusterIP
```

Then access via port-forward:
```bash
kubectl port-forward -n kodecd svc/kodecd-web 8080:80
# Open http://localhost:8080
```

### Option B: Production Install (with Ingress)

For production with a domain:

```bash
helm install kodecd ./helm/kodecd \
  --namespace kodecd \
  --set global.domain=kodecd.example.com \
  --set global.protocol=https \
  --set secrets.secretKeyBase=$SECRET_KEY_BASE \
  --set secrets.runnerToken=$RUNNER_TOKEN \
  --set postgresql.auth.password=$DB_PASSWORD \
  --set redis.auth.password=$REDIS_PASSWORD \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set "ingress.hosts[0].host=kodecd.example.com" \
  --set "ingress.hosts[0].paths[0].path=/" \
  --set "ingress.hosts[0].paths[0].pathType=Prefix"
```

### Option C: Using values.yaml

Create `my-values.yaml`:

```yaml
global:
  domain: kodecd.example.com
  protocol: https

secrets:
  secretKeyBase: "paste-generated-secret-key-base-here"
  runnerToken: "paste-generated-runner-token-here"

postgresql:
  auth:
    password: "secure-database-password"

redis:
  auth:
    password: "secure-redis-password"

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: kodecd.example.com
      paths:
        - path: /
          pathType: Prefix
```

Install:
```bash
helm install kodecd ./helm/kodecd -f my-values.yaml --namespace kodecd
```

## 4. Wait for Deployment

```bash
# Watch pods come up
kubectl get pods -n kodecd -w

# Check all are running
kubectl get pods -n kodecd
```

You should see:
```
NAME                              READY   STATUS    RESTARTS   AGE
kodecd-postgresql-0               1/1     Running   0          2m
kodecd-redis-master-0             1/1     Running   0          2m
kodecd-runner-xxx                 1/1     Running   0          1m
kodecd-sidekiq-xxx                1/1     Running   0          1m
kodecd-web-xxx                    1/1     Running   0          1m
```

## 5. Access KodeCD

### If using port-forward:
```bash
kubectl port-forward -n kodecd svc/kodecd-web 8080:80
```
Open http://localhost:8080

### If using Ingress:
Open https://kodecd.example.com

### If using NodePort:
```bash
export NODE_PORT=$(kubectl get svc kodecd-web -n kodecd -o jsonpath='{.spec.ports[0].nodePort}')
export NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
echo "http://$NODE_IP:$NODE_PORT"
```

## 6. Create First User

On first access, you'll be prompted to create an admin account.

## Common Commands

### View logs
```bash
# Web logs
kubectl logs -n kodecd -l app.kubernetes.io/component=web -f

# Sidekiq logs
kubectl logs -n kodecd -l app.kubernetes.io/component=sidekiq -f

# Runner logs
kubectl logs -n kodecd -l app.kubernetes.io/component=runner -f
```

### Rails console
```bash
kubectl exec -it -n kodecd deployment/kodecd-web -- bundle exec rails console
```

### Database migrations
```bash
kubectl exec -it -n kodecd deployment/kodecd-web -- bundle exec rails db:migrate
```

### Restart services
```bash
kubectl rollout restart deployment/kodecd-web -n kodecd
kubectl rollout restart deployment/kodecd-sidekiq -n kodecd
```

## Upgrade

```bash
helm upgrade kodecd ./helm/kodecd -f my-values.yaml --namespace kodecd
```

## Uninstall

```bash
# Remove KodeCD
helm uninstall kodecd -n kodecd

# Remove persistent data (WARNING: This deletes all data!)
kubectl delete pvc -n kodecd -l app.kubernetes.io/instance=kodecd

# Remove namespace
kubectl delete namespace kodecd
```

## Troubleshooting

### Pods stuck in Pending
Check PVC status:
```bash
kubectl get pvc -n kodecd
```

### Init container failing
Check init container logs:
```bash
kubectl logs -n kodecd <pod-name> -c db-migrate
```

### Database connection error
Verify PostgreSQL is running:
```bash
kubectl get pods -n kodecd -l app.kubernetes.io/name=postgresql
```

### Check all resources
```bash
kubectl get all -n kodecd
```

## Next Steps

1. Configure SMTP for email notifications
2. Set up SSL/TLS certificates
3. Configure backup strategy
4. Set up monitoring and logging
5. Configure auto-scaling

For detailed configuration, see [README.md](README.md)
