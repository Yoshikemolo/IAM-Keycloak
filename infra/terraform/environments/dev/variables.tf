# -----------------------------------------------------------------------------
# X-IAM Platform -- Dev Environment -- Variables
# -----------------------------------------------------------------------------
# Re-declares all root-level variables so they can be set via terraform.tfvars.
# Descriptions and validations are inherited from the root variables.tf.
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "org_name" {
  description = "Organisation short name."
  type        = string
  default     = "xiam"
}

variable "primary_region" {
  description = "Primary GCP region."
  type        = string
  default     = "europe-west1"
}

variable "secondary_region" {
  description = "Secondary GCP region."
  type        = string
  default     = "europe-southwest1"
}

variable "multi_region_enabled" {
  description = "Multi-region deployment."
  type        = bool
  default     = false
}

# ---- Networking ----

variable "vpc_cidr_primary" {
  type    = string
  default = "10.0.0.0/20"
}

variable "vpc_cidr_secondary" {
  type    = string
  default = "10.0.16.0/20"
}

variable "pods_cidr_primary" {
  type    = string
  default = "10.4.0.0/14"
}

variable "services_cidr_primary" {
  type    = string
  default = "10.8.0.0/20"
}

variable "pods_cidr_secondary" {
  type    = string
  default = "10.12.0.0/14"
}

variable "services_cidr_secondary" {
  type    = string
  default = "10.16.0.0/20"
}

# ---- GKE ----

variable "kubernetes_version" {
  type    = string
  default = "1.31"
}

variable "system_node_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "system_node_count" {
  type    = number
  default = 1
}

variable "system_node_min" {
  type    = number
  default = 1
}

variable "system_node_max" {
  type    = number
  default = 2
}

variable "keycloak_node_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "keycloak_node_count" {
  type    = number
  default = 1
}

variable "keycloak_node_min" {
  type    = number
  default = 1
}

variable "keycloak_node_max" {
  type    = number
  default = 2
}

variable "gke_private_endpoint" {
  type    = bool
  default = false
}

# ---- Database ----

variable "db_tier" {
  type    = string
  default = "db-custom-1-3840"
}

variable "db_high_availability" {
  type    = bool
  default = false
}

variable "db_disk_size_gb" {
  type    = number
  default = 10
}

variable "db_backup_enabled" {
  type    = bool
  default = true
}

variable "db_backup_retention_days" {
  type    = number
  default = 7
}

variable "db_maintenance_day" {
  type    = number
  default = 7
}

variable "db_maintenance_hour" {
  type    = number
  default = 3
}

# ---- Keycloak ----

variable "keycloak_replicas" {
  type    = number
  default = 1
}

variable "keycloak_image_tag" {
  type    = string
  default = "26.4.2"
}

variable "keycloak_hostname" {
  type    = string
  default = "iam-dev.xiam.dev"
}

variable "keycloak_hpa_min" {
  type    = number
  default = 1
}

variable "keycloak_hpa_max" {
  type    = number
  default = 3
}

variable "keycloak_cpu_request" {
  type    = string
  default = "250m"
}

variable "keycloak_memory_request" {
  type    = string
  default = "512Mi"
}

variable "keycloak_cpu_limit" {
  type    = string
  default = "1"
}

variable "keycloak_memory_limit" {
  type    = string
  default = "1Gi"
}

# ---- Observability ----

variable "observability_enabled" {
  type    = bool
  default = true
}

variable "grafana_admin_password" {
  type      = string
  default   = "changeme"
  sensitive = true
}

# ---- Labels ----

variable "labels" {
  type    = map(string)
  default = {}
}
