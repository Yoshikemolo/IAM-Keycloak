# Observability Module

## Overview

Deploys a complete observability stack on GKE for the X-IAM platform, providing metrics, logs, and traces.

## Components

| Component | Chart | Purpose |
|-----------|-------|---------|
| kube-prometheus-stack | prometheus-community/kube-prometheus-stack | Prometheus, Grafana, Alertmanager, recording/alerting rules |
| Loki | grafana/loki | Log aggregation and querying |
| OpenTelemetry Collector | open-telemetry/opentelemetry-collector | OTLP trace/metric ingestion and routing |

## Keycloak Integration

A Prometheus `ServiceMonitor` is automatically created to scrape Keycloak's `/metrics` endpoint (requires `KC_METRICS_ENABLED=true` in the Keycloak deployment). Pass the Keycloak namespace via the `keycloak_namespace` variable to enable this.

## Data Flow

```
Keycloak --OTLP--> OTel Collector --metrics--> Prometheus
                                   --traces-->  Debug (or Tempo)

Keycloak --stdout--> GKE Logging --Loki agent--> Loki --> Grafana
```

## Usage

```hcl
module "observability" {
  source = "../../modules/observability"

  project_id             = var.project_id
  environment            = "prod"
  org_name               = "xiam"
  grafana_admin_password = var.grafana_admin_password

  prometheus_retention    = "30d"
  prometheus_storage_size = "100Gi"
  loki_retention          = "720h"
  keycloak_namespace      = module.keycloak.namespace
}
```
