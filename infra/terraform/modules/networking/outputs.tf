# -----------------------------------------------------------------------------
# Networking Module -- Outputs
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "Self-link of the VPC network."
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "Name of the VPC network."
  value       = google_compute_network.vpc.name
}

output "primary_subnet_id" {
  description = "Self-link of the primary-region subnet."
  value       = google_compute_subnetwork.primary.id
}

output "primary_subnet_name" {
  description = "Name of the primary-region subnet."
  value       = google_compute_subnetwork.primary.name
}

output "secondary_subnet_id" {
  description = "Self-link of the secondary-region subnet (null if multi-region disabled)."
  value       = var.multi_region_enabled ? google_compute_subnetwork.secondary[0].id : null
}

output "secondary_subnet_name" {
  description = "Name of the secondary-region subnet (null if multi-region disabled)."
  value       = var.multi_region_enabled ? google_compute_subnetwork.secondary[0].name : null
}

output "pods_range_name_primary" {
  description = "Name of the secondary IP range for pods in the primary subnet."
  value       = google_compute_subnetwork.primary.secondary_ip_range[0].range_name
}

output "services_range_name_primary" {
  description = "Name of the secondary IP range for services in the primary subnet."
  value       = google_compute_subnetwork.primary.secondary_ip_range[1].range_name
}

output "pods_range_name_secondary" {
  description = "Name of the secondary IP range for pods in the secondary subnet."
  value       = var.multi_region_enabled ? google_compute_subnetwork.secondary[0].secondary_ip_range[0].range_name : null
}

output "services_range_name_secondary" {
  description = "Name of the secondary IP range for services in the secondary subnet."
  value       = var.multi_region_enabled ? google_compute_subnetwork.secondary[0].secondary_ip_range[1].range_name : null
}

output "private_services_connection" {
  description = "The private VPC peering connection for Google-managed services."
  value       = google_service_networking_connection.private_services.id
}
