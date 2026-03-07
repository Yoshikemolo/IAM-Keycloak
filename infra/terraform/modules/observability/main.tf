# -----------------------------------------------------------------------------
# X-IAM Platform -- Observability Module
# -----------------------------------------------------------------------------
# Deploys the full observability stack on GKE via Helm:
#
#   1. kube-prometheus-stack  -- Prometheus, Grafana, Alertmanager, and a
#                                curated set of recording/alerting rules plus
#                                Grafana dashboards for Kubernetes.
#   2. Loki                   -- Log aggregation system (Grafana Loki).
#   3. OpenTelemetry Collector -- Receives traces and metrics from Keycloak
#                                 and forwards them to the appropriate backends.
#
# All components are deployed into a dedicated "monitoring" namespace.
# Grafana is pre-configured with Prometheus and Loki data sources.
# -----------------------------------------------------------------------------

locals {
  labels = merge(var.labels, {
    project     = var.org_name
    environment = var.environment
    managed_by  = "terraform"
    module      = "observability"
  })

  prefix    = "${var.org_name}-${var.environment}"
  namespace = "${local.prefix}-monitoring"
}

# ---------------------------------------------------------------------------
# Monitoring Namespace
# ---------------------------------------------------------------------------

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name   = local.namespace
    labels = local.labels
  }
}

# ---------------------------------------------------------------------------
# kube-prometheus-stack
# ---------------------------------------------------------------------------
# Deploys Prometheus Operator, Prometheus server, Alertmanager, Grafana, and
# default Kubernetes recording/alerting rules.  ServiceMonitors for Keycloak
# metrics are created separately or via labels.

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.kube_prometheus_stack_version

  timeout         = 900
  atomic          = true
  cleanup_on_fail = true
  wait            = true

  # ---- Grafana Configuration ----
  set {
    name  = "grafana.enabled"
    value = "true"
  }

  set_sensitive {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }

  set {
    name  = "grafana.persistence.enabled"
    value = "true"
  }

  set {
    name  = "grafana.persistence.size"
    value = "10Gi"
  }

  set {
    name  = "grafana.persistence.storageClassName"
    value = "standard-rwo"
  }

  # Grafana service type -- ClusterIP by default; access via Ingress or
  # port-forward.
  set {
    name  = "grafana.service.type"
    value = "ClusterIP"
  }

  # ---- Prometheus Configuration ----
  set {
    name  = "prometheus.prometheusSpec.retention"
    value = var.prometheus_retention
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "standard-rwo"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = var.prometheus_storage_size
  }

  # Enable ServiceMonitor auto-discovery across all namespaces.
  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  # ---- Alertmanager ----
  set {
    name  = "alertmanager.enabled"
    value = var.alertmanager_enabled ? "true" : "false"
  }

  set {
    name  = "alertmanager.alertmanagerSpec.retention"
    value = "120h"
  }

  # ---- Node Exporter ----
  set {
    name  = "nodeExporter.enabled"
    value = "true"
  }

  # ---- Common Labels ----
  set {
    name  = "commonLabels.project"
    value = var.org_name
  }

  set {
    name  = "commonLabels.environment"
    value = var.environment
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# ---------------------------------------------------------------------------
# Loki (Log Aggregation)
# ---------------------------------------------------------------------------
# Deploys Grafana Loki in single-binary mode (suitable for dev/qa) or
# distributed mode (for production).  Grafana's kube-prometheus-stack
# automatically discovers the Loki data source when properly labelled.

resource "helm_release" "loki" {
  name       = "loki"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = var.loki_version

  timeout         = 600
  atomic          = true
  cleanup_on_fail = true
  wait            = true

  # Deploy in single-binary mode for simplicity; switch to distributed for
  # high-volume production workloads.
  set {
    name  = "deploymentMode"
    value = var.loki_deployment_mode
  }

  set {
    name  = "singleBinary.replicas"
    value = var.loki_deployment_mode == "SingleBinary" ? "1" : "0"
  }

  # Disable the built-in gateway in single-binary mode.
  set {
    name  = "gateway.enabled"
    value = var.loki_deployment_mode == "SingleBinary" ? "false" : "true"
  }

  # Use filesystem storage for dev/qa; production should use GCS.
  set {
    name  = "loki.storage.type"
    value = var.loki_storage_type
  }

  set {
    name  = "loki.commonConfig.replication_factor"
    value = "1"
  }

  set {
    name  = "loki.schemaConfig.configs[0].from"
    value = "2024-01-01"
  }

  set {
    name  = "loki.schemaConfig.configs[0].store"
    value = "tsdb"
  }

  set {
    name  = "loki.schemaConfig.configs[0].object_store"
    value = var.loki_storage_type
  }

  set {
    name  = "loki.schemaConfig.configs[0].schema"
    value = "v13"
  }

  set {
    name  = "loki.schemaConfig.configs[0].index.prefix"
    value = "index_"
  }

  set {
    name  = "loki.schemaConfig.configs[0].index.period"
    value = "24h"
  }

  set {
    name  = "loki.limits_config.retention_period"
    value = var.loki_retention
  }

  # ---- Persistence ----
  set {
    name  = "singleBinary.persistence.enabled"
    value = "true"
  }

  set {
    name  = "singleBinary.persistence.size"
    value = var.loki_storage_size
  }

  # Disable components not needed in single-binary mode.
  set {
    name  = "backend.replicas"
    value = "0"
  }

  set {
    name  = "read.replicas"
    value = "0"
  }

  set {
    name  = "write.replicas"
    value = "0"
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# ---------------------------------------------------------------------------
# OpenTelemetry Collector
# ---------------------------------------------------------------------------
# Receives OTLP traces and metrics from Keycloak (and other services) and
# exports them to Prometheus (metrics) and optionally to Tempo or Jaeger
# (traces).

resource "helm_release" "otel_collector" {
  name       = "otel-collector"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  version    = var.otel_collector_version

  timeout         = 600
  atomic          = true
  cleanup_on_fail = true
  wait            = true

  # Deploy as a Deployment (not DaemonSet) -- a single collector instance is
  # sufficient for ~400 users.
  set {
    name  = "mode"
    value = "deployment"
  }

  set {
    name  = "replicaCount"
    value = var.otel_replicas
  }

  # ---- Ports ----
  set {
    name  = "ports.otlp.enabled"
    value = "true"
  }

  set {
    name  = "ports.otlp-http.enabled"
    value = "true"
  }

  set {
    name  = "ports.prometheus.enabled"
    value = "true"
  }

  # ---- Configuration ----
  # The collector configuration is passed as a YAML string.
  values = [<<-YAML
    config:
      receivers:
        otlp:
          protocols:
            grpc:
              endpoint: "0.0.0.0:4317"
            http:
              endpoint: "0.0.0.0:4318"

      processors:
        batch:
          timeout: 5s
          send_batch_size: 512
        memory_limiter:
          check_interval: 5s
          limit_mib: 512
          spike_limit_mib: 128
        resource:
          attributes:
            - key: environment
              value: "${var.environment}"
              action: upsert
            - key: platform
              value: "xiam"
              action: upsert

      exporters:
        prometheusremotewrite:
          endpoint: "http://kube-prometheus-stack-prometheus.${local.namespace}.svc.cluster.local:9090/api/v1/write"
        debug:
          verbosity: basic

      service:
        pipelines:
          traces:
            receivers: [otlp]
            processors: [memory_limiter, batch, resource]
            exporters: [debug]
          metrics:
            receivers: [otlp]
            processors: [memory_limiter, batch, resource]
            exporters: [prometheusremotewrite]
  YAML
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.kube_prometheus_stack,
  ]
}

# ---------------------------------------------------------------------------
# Keycloak ServiceMonitor
# ---------------------------------------------------------------------------
# Creates a Prometheus ServiceMonitor that scrapes the Keycloak /metrics
# endpoint.  The kube-prometheus-stack Prometheus instance automatically
# picks this up because serviceMonitorSelectorNilUsesHelmValues is false.

resource "kubernetes_manifest" "keycloak_service_monitor" {
  count = var.keycloak_namespace != "" ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "${local.prefix}-keycloak-metrics"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      labels = merge(local.labels, {
        "release" = "kube-prometheus-stack"
      })
    }
    spec = {
      namespaceSelector = {
        matchNames = [var.keycloak_namespace]
      }
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "keycloak"
        }
      }
      endpoints = [
        {
          port     = "http"
          path     = "/metrics"
          interval = "30s"
        }
      ]
    }
  }

  depends_on = [helm_release.kube_prometheus_stack]
}
