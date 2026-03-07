# -----------------------------------------------------------------------------
# X-IAM Platform -- Root-Level Outputs
# -----------------------------------------------------------------------------
# These outputs are re-exported from child modules so that CI/CD pipelines and
# other automation can consume key values (cluster endpoints, database
# connection strings, etc.) from the Terraform state.
# -----------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

output "vpc_id" {
  description = "Self-link of the VPC network."
  value       = module.networking.vpc_id
}

output "vpc_name" {
  description = "Name of the VPC network."
  value       = module.networking.vpc_name
}

output "primary_subnet_id" {
  description = "Self-link of the primary-region subnet."
  value       = module.networking.primary_subnet_id
}

output "secondary_subnet_id" {
  description = "Self-link of the secondary-region subnet (null if multi-region is disabled)."
  value       = module.networking.secondary_subnet_id
}

# ---------------------------------------------------------------------------
# GKE -- Primary Cluster
# ---------------------------------------------------------------------------

output "primary_cluster_name" {
  description = "Name of the primary GKE cluster."
  value       = module.gke_primary.cluster_name
}

output "primary_cluster_endpoint" {
  description = "Endpoint (IP) of the primary GKE control plane."
  value       = module.gke_primary.cluster_endpoint
  sensitive   = true
}

output "primary_cluster_ca_certificate" {
  description = "Base64-encoded CA certificate of the primary GKE cluster."
  value       = module.gke_primary.cluster_ca_certificate
  sensitive   = true
}

# ---------------------------------------------------------------------------
# GKE -- Secondary Cluster (prod only)
# ---------------------------------------------------------------------------

output "secondary_cluster_name" {
  description = "Name of the secondary GKE cluster (null if multi-region is disabled)."
  value       = var.multi_region_enabled ? module.gke_secondary[0].cluster_name : null
}

output "secondary_cluster_endpoint" {
  description = "Endpoint of the secondary GKE control plane (null if multi-region is disabled)."
  value       = var.multi_region_enabled ? module.gke_secondary[0].cluster_endpoint : null
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Cloud SQL (PostgreSQL)
# ---------------------------------------------------------------------------

output "db_connection_name" {
  description = "Cloud SQL instance connection name (project:region:instance)."
  value       = module.postgresql.connection_name
}

output "db_private_ip" {
  description = "Private IP address of the Cloud SQL instance."
  value       = module.postgresql.private_ip
  sensitive   = true
}

output "db_name" {
  description = "Name of the Keycloak database."
  value       = module.postgresql.db_name
}

# ---------------------------------------------------------------------------
# Keycloak
# ---------------------------------------------------------------------------

output "keycloak_namespace" {
  description = "Kubernetes namespace where Keycloak is deployed."
  value       = module.keycloak.namespace
}

output "keycloak_service_account" {
  description = "Kubernetes service account used by Keycloak pods."
  value       = module.keycloak.service_account
}
