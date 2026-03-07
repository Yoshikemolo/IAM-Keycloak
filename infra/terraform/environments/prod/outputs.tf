# -----------------------------------------------------------------------------
# X-IAM Platform -- Prod Environment -- Outputs
# -----------------------------------------------------------------------------

output "vpc_name" {
  description = "VPC network name."
  value       = module.networking.vpc_name
}

# ---- Primary Cluster ----

output "primary_cluster_name" {
  description = "Primary GKE cluster name."
  value       = module.gke_primary.cluster_name
}

output "primary_cluster_endpoint" {
  description = "Primary GKE control plane endpoint."
  value       = module.gke_primary.cluster_endpoint
  sensitive   = true
}

# ---- Secondary Cluster ----

output "secondary_cluster_name" {
  description = "Secondary GKE cluster name (null if multi-region disabled)."
  value       = var.multi_region_enabled ? module.gke_secondary[0].cluster_name : null
}

output "secondary_cluster_endpoint" {
  description = "Secondary GKE control plane endpoint (null if multi-region disabled)."
  value       = var.multi_region_enabled ? module.gke_secondary[0].cluster_endpoint : null
  sensitive   = true
}

# ---- Database ----

output "db_connection_name" {
  description = "Cloud SQL connection name."
  value       = module.postgresql.connection_name
}

output "db_private_ip" {
  description = "Cloud SQL private IP."
  value       = module.postgresql.private_ip
  sensitive   = true
}

# ---- Keycloak ----

output "keycloak_namespace" {
  description = "Keycloak Kubernetes namespace."
  value       = module.keycloak.namespace
}

output "keycloak_hostname" {
  description = "Keycloak public hostname."
  value       = module.keycloak.keycloak_hostname
}

output "keycloak_gcp_service_account" {
  description = "GCP service account email for Keycloak Workload Identity."
  value       = module.keycloak.gcp_service_account_email
}
