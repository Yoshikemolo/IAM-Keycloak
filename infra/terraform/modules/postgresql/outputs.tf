# -----------------------------------------------------------------------------
# PostgreSQL Module -- Outputs
# -----------------------------------------------------------------------------

output "instance_name" {
  description = "Name of the Cloud SQL instance."
  value       = google_sql_database_instance.keycloak.name
}

output "connection_name" {
  description = "Cloud SQL connection name (project:region:instance)."
  value       = google_sql_database_instance.keycloak.connection_name
}

output "private_ip" {
  description = "Private IP address of the Cloud SQL instance."
  value       = google_sql_database_instance.keycloak.private_ip_address
  sensitive   = true
}

output "db_name" {
  description = "Name of the Keycloak database."
  value       = google_sql_database.keycloak.name
}

output "db_user" {
  description = "Database username for Keycloak."
  value       = google_sql_user.keycloak.name
}

output "db_password" {
  description = "Database password for Keycloak (randomly generated)."
  value       = random_password.db_password.result
  sensitive   = true
}

output "db_port" {
  description = "PostgreSQL port (always 5432 for Cloud SQL)."
  value       = 5432
}
