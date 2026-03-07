# X-IAM Keycloak Helm Chart

Enterprise-grade Helm chart for deploying [Keycloak 26](https://www.keycloak.org/) on Google Kubernetes Engine (GKE) as part of the X-IAM Identity and Access Management platform.

## Overview

This chart deploys Keycloak 26.4.2 with the following capabilities:

- **High Availability** -- Multi-replica deployment with Infinispan distributed caching (KUBE_PING discovery)
- **Auto-scaling** -- HorizontalPodAutoscaler with CPU and memory targets
- **Security hardening** -- Non-root containers, read-only root filesystem, dropped capabilities, network policies
- **Observability** -- Prometheus metrics endpoint, ServiceMonitor, health probes on dedicated management port (9000)
- **GKE integration** -- Workload Identity, topology spread across availability zones, dedicated node pools
- **TLS termination** -- NGINX Ingress with cert-manager automatic certificate provisioning
- **Multi-environment** -- Separate values files for dev, QA, and production

## Prerequisites

| Requirement | Minimum Version |
|---|---|
| Kubernetes | 1.27+ |
| Helm | 3.12+ |
| NGINX Ingress Controller | 1.9+ |
| cert-manager (optional) | 1.13+ |
| Prometheus Operator (optional) | 0.70+ |

## Quick Start

```bash
# Add the chart (if hosted in a Helm repository)
# helm repo add xiam https://charts.xiam.example.com
# helm repo update

# Install with default values (base configuration)
helm upgrade --install xiam-kc ./infra/helm/keycloak \
  -n xiam --create-namespace

# Install for a specific environment
helm upgrade --install xiam-kc ./infra/helm/keycloak \
  -f ./infra/helm/keycloak/values.yaml \
  -f ./infra/helm/keycloak/values-dev.yaml \
  -n xiam-dev --create-namespace

helm upgrade --install xiam-kc ./infra/helm/keycloak \
  -f ./infra/helm/keycloak/values.yaml \
  -f ./infra/helm/keycloak/values-qa.yaml \
  -n xiam-qa --create-namespace

helm upgrade --install xiam-kc ./infra/helm/keycloak \
  -f ./infra/helm/keycloak/values.yaml \
  -f ./infra/helm/keycloak/values-prod.yaml \
  -n xiam-prod --create-namespace
```

## Verify the Deployment

```bash
# Check pod status
kubectl get pods -n xiam-prod -l app.kubernetes.io/name=xiam-keycloak

# Run the Helm test (health endpoint check)
helm test xiam-kc -n xiam-prod

# View post-install notes
helm get notes xiam-kc -n xiam-prod

# Access Keycloak locally via port-forward
kubectl port-forward svc/xiam-kc-xiam-keycloak 8080:8080 -n xiam-prod
```

## Uninstall

```bash
helm uninstall xiam-kc -n xiam-prod
```

## Configuration Reference

### General

| Parameter | Description | Default |
|---|---|---|
| `replicaCount` | Number of Keycloak replicas | `2` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override fully qualified name | `""` |
| `revisionHistoryLimit` | ReplicaSets to retain | `5` |
| `terminationGracePeriodSeconds` | Graceful shutdown window | `60` |

### Image

| Parameter | Description | Default |
|---|---|---|
| `image.repository` | Container image repository | `quay.io/keycloak/keycloak` |
| `image.tag` | Container image tag | `26.4.2` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Registry pull secrets | `[]` |

### Keycloak

| Parameter | Description | Default |
|---|---|---|
| `keycloak.hostname` | Public hostname | `iam.xiam.example.com` |
| `keycloak.hostnameStrict` | Enforce strict hostname | `true` |
| `keycloak.proxy` | Proxy header mode | `xforwarded` |
| `keycloak.optimized` | Use optimized build | `false` |
| `keycloak.features` | Enabled features | `token-exchange,...` |
| `keycloak.logLevel` | Log level | `INFO` |
| `keycloak.logFormat` | Log output format | `default` |
| `keycloak.javaOpts` | JVM options | `-XX:MaxRAMPercentage=70.0` |

### Database

| Parameter | Description | Default |
|---|---|---|
| `keycloak.database.vendor` | DB vendor | `oracle` |
| `keycloak.database.url` | JDBC URL | `jdbc:oracle:thin:@//oracle-db:1521/keycloakdb` |
| `keycloak.database.username` | DB username | `keycloak` |
| `keycloak.database.password` | DB password (non-prod only) | `changeme` |
| `keycloak.database.existingSecret` | Pre-existing Secret name | `""` |

### Admin

| Parameter | Description | Default |
|---|---|---|
| `keycloak.admin.username` | Admin username | `admin` |
| `keycloak.admin.password` | Admin password (non-prod only) | `changeme` |
| `keycloak.admin.existingSecret` | Pre-existing Secret name | `""` |

### Cache

| Parameter | Description | Default |
|---|---|---|
| `keycloak.cache.type` | Cache type | `ispn` |
| `keycloak.cache.stack` | JGroups stack | `kubernetes` |
| `keycloak.cache.jgroupsPort` | JGroups port | `7800` |

### Service

| Parameter | Description | Default |
|---|---|---|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |

### Ingress

| Parameter | Description | Default |
|---|---|---|
| `ingress.enabled` | Enable Ingress | `true` |
| `ingress.ingressClassName` | Ingress class | `nginx` |
| `ingress.annotations` | Ingress annotations | See `values.yaml` |
| `ingress.hosts` | Host rules | `[{host: iam.xiam.example.com}]` |
| `ingress.tls` | TLS configuration | See `values.yaml` |

### Autoscaling

| Parameter | Description | Default |
|---|---|---|
| `autoscaling.enabled` | Enable HPA | `true` |
| `autoscaling.minReplicas` | Minimum replicas | `2` |
| `autoscaling.maxReplicas` | Maximum replicas | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | CPU target | `70` |
| `autoscaling.targetMemoryUtilizationPercentage` | Memory target | `80` |

### Pod Disruption Budget

| Parameter | Description | Default |
|---|---|---|
| `podDisruptionBudget.enabled` | Enable PDB | `true` |
| `podDisruptionBudget.minAvailable` | Min available pods | `1` |

### Security

| Parameter | Description | Default |
|---|---|---|
| `podSecurityContext.runAsNonRoot` | Pod runs as non-root | `true` |
| `podSecurityContext.runAsUser` | Pod UID | `1000` |
| `securityContext.readOnlyRootFilesystem` | Read-only root FS | `true` |
| `securityContext.allowPrivilegeEscalation` | Privilege escalation | `false` |
| `securityContext.capabilities.drop` | Dropped capabilities | `[ALL]` |

### ServiceAccount

| Parameter | Description | Default |
|---|---|---|
| `serviceAccount.create` | Create ServiceAccount | `true` |
| `serviceAccount.annotations` | SA annotations (Workload Identity) | See `values.yaml` |

### Metrics

| Parameter | Description | Default |
|---|---|---|
| `metrics.enabled` | Enable metrics endpoint | `true` |
| `metrics.serviceMonitor.enabled` | Create ServiceMonitor | `true` |
| `metrics.serviceMonitor.interval` | Scrape interval | `30s` |

### Network Policy

| Parameter | Description | Default |
|---|---|---|
| `networkPolicy.enabled` | Enable NetworkPolicy | `true` |
| `networkPolicy.ingressControllerNamespace` | Ingress NS | `ingress-nginx` |
| `networkPolicy.monitoringNamespace` | Monitoring NS | `monitoring` |

### Scheduling

| Parameter | Description | Default |
|---|---|---|
| `nodeSelector` | Node selector labels | `{}` |
| `tolerations` | Pod tolerations | `[]` |
| `affinity` | Custom affinity rules | `{}` (anti-affinity default) |
| `topologySpreadConstraints` | Topology spread | `[]` (zone spread default) |

## Environment Strategy

| Environment | Replicas | HPA | PDB | Log Level | Resources |
|---|---|---|---|---|---|
| **dev** | 1 | Disabled | Disabled | DEBUG | 250m/256Mi - 1000m/1Gi |
| **qa** | 2 | 2-6 | min 1 | INFO | 500m/512Mi - 2000m/2Gi |
| **prod** | 3 | 3-10 | min 2 | WARN | 1000m/1Gi - 4000m/4Gi |

## Production Secrets Management

In production, never store credentials in values files.  Use one of these approaches:

1. **External Secrets Operator** -- Syncs secrets from GCP Secret Manager into Kubernetes Secrets.
2. **Sealed Secrets** -- Encrypts secrets that can be safely committed to Git.
3. **Manual creation** -- Create secrets before deploying the chart.

```bash
# Example: Create database secret manually
kubectl create secret generic xiam-keycloak-db-prod \
  --from-literal=KC_DB_PASSWORD='<real-password>' \
  -n xiam-prod

# Example: Create admin secret manually
kubectl create secret generic xiam-keycloak-admin-prod \
  --from-literal=KEYCLOAK_ADMIN='admin' \
  --from-literal=KEYCLOAK_ADMIN_PASSWORD='<real-password>' \
  -n xiam-prod
```

Then reference them in `values-prod.yaml`:

```yaml
keycloak:
  database:
    existingSecret: "xiam-keycloak-db-prod"
  admin:
    existingSecret: "xiam-keycloak-admin-prod"
```

## Architecture

```
                         Internet
                            |
                     [Cloud Load Balancer]
                            |
                     [NGINX Ingress + TLS]
                            |
              +-------------+-------------+
              |             |             |
         [KC Pod 1]    [KC Pod 2]    [KC Pod 3]
         Zone A        Zone B        Zone A
              |             |             |
              +------+------+------+------+
                     |             |
              [Infinispan KUBE_PING]
                     |
              [Oracle Database]
              (Cloud SQL / RDS)
```

## Troubleshooting

### Pods stuck in CrashLoopBackOff

Check the logs for startup errors (database connectivity, configuration issues):

```bash
kubectl logs -l app.kubernetes.io/name=xiam-keycloak -n xiam-prod --tail=100
```

### Pods fail readiness probe

Verify the management port is accessible:

```bash
kubectl exec -it <pod-name> -n xiam-prod -- curl -s http://localhost:9000/health/ready
```

### JGroups cluster not forming

Verify RBAC permissions for KUBE_PING discovery:

```bash
kubectl auth can-i list pods --as=system:serviceaccount:xiam-prod:<sa-name> -n xiam-prod
```

### Database connection refused

Check the database URL and credentials in the ConfigMap and Secret:

```bash
kubectl get configmap <fullname>-config -n xiam-prod -o yaml | grep KC_DB
kubectl get secret <fullname>-db -n xiam-prod -o jsonpath='{.data.KC_DB_PASSWORD}' | base64 -d
```

## Related Documentation

- [Target Architecture](../../../doc/01-target-architecture.md)
- [Infrastructure as Code](../../../doc/05-infrastructure-as-code.md)
- [Keycloak Configuration](../../../doc/04-keycloak-configuration.md)
- [Disaster Recovery](../../../doc/17-disaster-recovery.md)
- [Operations Runbook](../../../doc/16-operations-runbook.md)
