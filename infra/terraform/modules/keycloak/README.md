# Keycloak Module

## Overview

Deploys Keycloak 26.x on GKE using the Bitnami Helm chart with production-ready configuration, Workload Identity, HPA, and PDB.

## Resources Created

| Resource | Description |
|----------|-------------|
| `kubernetes_namespace` | Dedicated namespace for Keycloak |
| `google_service_account` | GCP SA for Workload Identity |
| `google_service_account_iam_member` | Workload Identity binding |
| `google_project_iam_member` | Cloud SQL client role |
| `kubernetes_secret` | Database credentials |
| `helm_release` | Bitnami Keycloak chart |
| `kubernetes_horizontal_pod_autoscaler_v2` | CPU/memory-based HPA |
| `kubernetes_pod_disruption_budget_v1` | PDB (minAvailable: 1) |

## Keycloak Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `KC_DB` | postgres | Database vendor |
| `KC_HOSTNAME` | Configurable | Public hostname for Keycloak |
| `KC_PROXY_HEADERS` | xforwarded | Trust X-Forwarded-* headers from load balancer |
| `KC_HEALTH_ENABLED` | true | Expose /health endpoints |
| `KC_METRICS_ENABLED` | true | Expose /metrics for Prometheus |
| `KC_CACHE` | ispn | Infinispan clustering |
| `KC_CACHE_STACK` | kubernetes | JGroups Kubernetes discovery |

## Node Affinity

Keycloak pods are configured with a toleration for `workload=keycloak:NoSchedule` and a nodeSelector for `node_pool=keycloak`, ensuring they run exclusively on the dedicated Keycloak node pool.

## Usage

```hcl
module "keycloak" {
  source = "../../modules/keycloak"

  project_id         = var.project_id
  environment        = "prod"
  org_name           = "xiam"
  keycloak_hostname  = "iam.xiam.io"
  replicas           = 3
  hpa_min            = 2
  hpa_max            = 10

  db_host     = module.postgresql.private_ip
  db_name     = module.postgresql.db_name
  db_user     = module.postgresql.db_user
  db_password = module.postgresql.db_password
}
```
