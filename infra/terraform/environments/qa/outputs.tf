# -----------------------------------------------------------------------------
# X-IAM Platform -- QA Environment -- Outputs
# -----------------------------------------------------------------------------

output "vpc_name" {
  description = "VPC network name."
  value       = module.networking.vpc_name
}

output "primary_cluster_name" {
  description = "GKE cluster name."
  value       = module.gke_primary.cluster_name
}

output "primary_cluster_endpoint" {
  description = "GKE control plane endpoint."
  value       = module.gke_primary.cluster_endpoint
  sensitive   = true
}

output "db_connection_name" {
  description = "Cloud SQL connection name."
  value       = module.postgresql.connection_name
}

output "db_private_ip" {
  description = "Cloud SQL private IP."
  value       = module.postgresql.private_ip
  sensitive   = true
}

output "keycloak_namespace" {
  description = "Keycloak Kubernetes namespace."
  value       = module.keycloak.namespace
}

output "keycloak_hostname" {
  description = "Keycloak public hostname."
  value       = module.keycloak.keycloak_hostname
}
