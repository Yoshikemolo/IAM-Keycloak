# -----------------------------------------------------------------------------
# GKE Cluster Module -- Outputs
# -----------------------------------------------------------------------------

output "cluster_name" {
  description = "Name of the GKE cluster."
  value       = google_container_cluster.cluster.name
}

output "cluster_id" {
  description = "Unique identifier of the GKE cluster."
  value       = google_container_cluster.cluster.id
}

output "cluster_endpoint" {
  description = "IP address of the GKE control plane."
  value       = google_container_cluster.cluster.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64-encoded CA certificate of the cluster."
  value       = google_container_cluster.cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "Location (region) of the cluster."
  value       = google_container_cluster.cluster.location
}

output "system_node_pool_name" {
  description = "Name of the system node pool."
  value       = google_container_node_pool.system.name
}

output "keycloak_node_pool_name" {
  description = "Name of the Keycloak-dedicated node pool."
  value       = google_container_node_pool.keycloak.name
}
