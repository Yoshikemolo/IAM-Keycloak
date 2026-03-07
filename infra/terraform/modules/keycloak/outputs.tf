# -----------------------------------------------------------------------------
# Keycloak Module -- Outputs
# -----------------------------------------------------------------------------

output "namespace" {
  description = "Kubernetes namespace where Keycloak is deployed."
  value       = kubernetes_namespace.keycloak.metadata[0].name
}

output "service_account" {
  description = "Kubernetes service account name used by Keycloak pods."
  value       = "${var.org_name}-${var.environment}-keycloak"
}

output "gcp_service_account_email" {
  description = "GCP service account email bound via Workload Identity."
  value       = google_service_account.keycloak.email
}

output "helm_release_name" {
  description = "Name of the Helm release."
  value       = helm_release.keycloak.name
}

output "helm_release_version" {
  description = "Deployed Helm chart version."
  value       = helm_release.keycloak.version
}

output "keycloak_hostname" {
  description = "Configured hostname for Keycloak."
  value       = var.keycloak_hostname
}
