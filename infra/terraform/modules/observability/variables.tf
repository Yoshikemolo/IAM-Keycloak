# -----------------------------------------------------------------------------
# Observability Module -- Input Variables
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, qa, prod)."
  type        = string
}

variable "org_name" {
  description = "Organisation / platform short name."
  type        = string
}

# ---- kube-prometheus-stack ----

variable "kube_prometheus_stack_version" {
  description = "Helm chart version for kube-prometheus-stack."
  type        = string
  default     = "67.9.0"
}

variable "grafana_admin_password" {
  description = "Grafana admin password."
  type        = string
  sensitive   = true
}

variable "prometheus_retention" {
  description = "Prometheus data retention period."
  type        = string
  default     = "15d"
}

variable "prometheus_storage_size" {
  description = "Persistent volume size for Prometheus."
  type        = string
  default     = "50Gi"
}

variable "alertmanager_enabled" {
  description = "Whether to deploy Alertmanager."
  type        = bool
  default     = true
}

# ---- Loki ----

variable "loki_version" {
  description = "Helm chart version for Grafana Loki."
  type        = string
  default     = "6.24.0"
}

variable "loki_deployment_mode" {
  description = "Loki deployment mode (SingleBinary or SimpleScalable)."
  type        = string
  default     = "SingleBinary"

  validation {
    condition     = contains(["SingleBinary", "SimpleScalable"], var.loki_deployment_mode)
    error_message = "loki_deployment_mode must be SingleBinary or SimpleScalable."
  }
}

variable "loki_storage_type" {
  description = "Loki storage backend (filesystem or gcs)."
  type        = string
  default     = "filesystem"

  validation {
    condition     = contains(["filesystem", "gcs"], var.loki_storage_type)
    error_message = "loki_storage_type must be filesystem or gcs."
  }
}

variable "loki_retention" {
  description = "Loki log retention period."
  type        = string
  default     = "168h"
}

variable "loki_storage_size" {
  description = "Persistent volume size for Loki."
  type        = string
  default     = "20Gi"
}

# ---- OpenTelemetry Collector ----

variable "otel_collector_version" {
  description = "Helm chart version for the OpenTelemetry Collector."
  type        = string
  default     = "0.108.0"
}

variable "otel_replicas" {
  description = "Number of OpenTelemetry Collector replicas."
  type        = number
  default     = 1
}

# ---- Keycloak Integration ----

variable "keycloak_namespace" {
  description = "Namespace where Keycloak is deployed (for ServiceMonitor). Empty string disables the ServiceMonitor."
  type        = string
  default     = ""
}

# ---- Labels ----

variable "labels" {
  description = "Labels to apply to all resources."
  type        = map(string)
  default     = {}
}
