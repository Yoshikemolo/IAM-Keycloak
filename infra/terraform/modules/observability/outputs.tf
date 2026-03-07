# -----------------------------------------------------------------------------
# Observability Module -- Outputs
# -----------------------------------------------------------------------------

output "monitoring_namespace" {
  description = "Kubernetes namespace where the observability stack is deployed."
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "prometheus_release_name" {
  description = "Helm release name for kube-prometheus-stack."
  value       = helm_release.kube_prometheus_stack.name
}

output "loki_release_name" {
  description = "Helm release name for Loki."
  value       = helm_release.loki.name
}

output "otel_collector_release_name" {
  description = "Helm release name for the OpenTelemetry Collector."
  value       = helm_release.otel_collector.name
}

output "grafana_service" {
  description = "Internal service name for Grafana (for port-forward or Ingress)."
  value       = "kube-prometheus-stack-grafana"
}

output "prometheus_service" {
  description = "Internal service name for Prometheus."
  value       = "kube-prometheus-stack-prometheus"
}
