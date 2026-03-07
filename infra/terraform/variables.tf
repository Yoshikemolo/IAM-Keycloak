# -----------------------------------------------------------------------------
# X-IAM Platform -- Root-Level Shared Variables
# -----------------------------------------------------------------------------
# Variables declared here are referenced by the environment-level main.tf files
# and passed down to child modules.  Every variable includes a description, a
# type constraint, and -- where applicable -- a validation block.
# -----------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Project and Environment
# ---------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID where all resources will be created."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID (6-30 lowercase alphanumeric/hyphens)."
  }
}

variable "environment" {
  description = "Deployment environment name (dev, qa, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "environment must be one of: dev, qa, prod."
  }
}

variable "org_name" {
  description = "Short organisation / platform name used as a prefix for resource naming."
  type        = string
  default     = "xiam"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,14}$", var.org_name))
    error_message = "org_name must be 2-15 lowercase alphanumeric characters or hyphens."
  }
}

# ---------------------------------------------------------------------------
# Regions
# ---------------------------------------------------------------------------

variable "primary_region" {
  description = "Primary GCP region (Belgium)."
  type        = string
  default     = "europe-west1"
}

variable "secondary_region" {
  description = "Secondary GCP region (Madrid) used for multi-region prod deployments."
  type        = string
  default     = "europe-southwest1"
}

variable "multi_region_enabled" {
  description = "Whether to deploy resources in both regions.  Typically true only for prod."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

variable "vpc_cidr_primary" {
  description = "Primary subnet CIDR for the primary region."
  type        = string
  default     = "10.0.0.0/20"
}

variable "vpc_cidr_secondary" {
  description = "Primary subnet CIDR for the secondary region."
  type        = string
  default     = "10.0.16.0/20"
}

variable "pods_cidr_primary" {
  description = "Secondary IP range for GKE pods in the primary region."
  type        = string
  default     = "10.4.0.0/14"
}

variable "services_cidr_primary" {
  description = "Secondary IP range for GKE services in the primary region."
  type        = string
  default     = "10.8.0.0/20"
}

variable "pods_cidr_secondary" {
  description = "Secondary IP range for GKE pods in the secondary region."
  type        = string
  default     = "10.12.0.0/14"
}

variable "services_cidr_secondary" {
  description = "Secondary IP range for GKE services in the secondary region."
  type        = string
  default     = "10.16.0.0/20"
}

# ---------------------------------------------------------------------------
# GKE
# ---------------------------------------------------------------------------

variable "kubernetes_version" {
  description = "GKE Kubernetes version channel or static version."
  type        = string
  default     = "1.31"
}

variable "system_node_machine_type" {
  description = "Machine type for the system node pool."
  type        = string
  default     = "e2-standard-2"
}

variable "system_node_count" {
  description = "Initial node count for the system node pool (per zone)."
  type        = number
  default     = 1
}

variable "system_node_min" {
  description = "Minimum node count for the system node pool autoscaler."
  type        = number
  default     = 1
}

variable "system_node_max" {
  description = "Maximum node count for the system node pool autoscaler."
  type        = number
  default     = 3
}

variable "keycloak_node_machine_type" {
  description = "Machine type for the Keycloak-dedicated node pool."
  type        = string
  default     = "e2-standard-4"
}

variable "keycloak_node_count" {
  description = "Initial node count for the Keycloak node pool (per zone)."
  type        = number
  default     = 1
}

variable "keycloak_node_min" {
  description = "Minimum node count for the Keycloak node pool autoscaler."
  type        = number
  default     = 1
}

variable "keycloak_node_max" {
  description = "Maximum node count for the Keycloak node pool autoscaler."
  type        = number
  default     = 3
}

variable "gke_private_endpoint" {
  description = "If true, the GKE control plane is accessible only from private networks."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Cloud SQL (PostgreSQL)
# ---------------------------------------------------------------------------

variable "db_tier" {
  description = "Cloud SQL machine tier (e.g. db-custom-2-8192)."
  type        = string
  default     = "db-custom-2-8192"
}

variable "db_high_availability" {
  description = "Enable Cloud SQL high-availability (regional) configuration."
  type        = bool
  default     = false
}

variable "db_disk_size_gb" {
  description = "Initial disk size in GB for the Cloud SQL instance."
  type        = number
  default     = 20

  validation {
    condition     = var.db_disk_size_gb >= 10
    error_message = "db_disk_size_gb must be at least 10 GB."
  }
}

variable "db_backup_enabled" {
  description = "Enable automated backups for Cloud SQL."
  type        = bool
  default     = true
}

variable "db_backup_retention_days" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7

  validation {
    condition     = var.db_backup_retention_days >= 1 && var.db_backup_retention_days <= 365
    error_message = "db_backup_retention_days must be between 1 and 365."
  }
}

variable "db_maintenance_day" {
  description = "Preferred maintenance window day (1=Mon .. 7=Sun)."
  type        = number
  default     = 7

  validation {
    condition     = var.db_maintenance_day >= 1 && var.db_maintenance_day <= 7
    error_message = "db_maintenance_day must be between 1 (Monday) and 7 (Sunday)."
  }
}

variable "db_maintenance_hour" {
  description = "Preferred maintenance window hour (UTC, 0-23)."
  type        = number
  default     = 3

  validation {
    condition     = var.db_maintenance_hour >= 0 && var.db_maintenance_hour <= 23
    error_message = "db_maintenance_hour must be between 0 and 23."
  }
}

# ---------------------------------------------------------------------------
# Keycloak
# ---------------------------------------------------------------------------

variable "keycloak_replicas" {
  description = "Number of Keycloak pod replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.keycloak_replicas >= 1
    error_message = "keycloak_replicas must be at least 1."
  }
}

variable "keycloak_image_tag" {
  description = "Keycloak container image tag (bitnami/keycloak)."
  type        = string
  default     = "26.4.2"
}

variable "keycloak_hostname" {
  description = "Public hostname for Keycloak (used in KC_HOSTNAME)."
  type        = string
  default     = "iam.xiam.dev"
}

variable "keycloak_hpa_min" {
  description = "HPA minimum replica count for Keycloak."
  type        = number
  default     = 1
}

variable "keycloak_hpa_max" {
  description = "HPA maximum replica count for Keycloak."
  type        = number
  default     = 3
}

variable "keycloak_cpu_request" {
  description = "CPU request for each Keycloak pod."
  type        = string
  default     = "500m"
}

variable "keycloak_memory_request" {
  description = "Memory request for each Keycloak pod."
  type        = string
  default     = "1Gi"
}

variable "keycloak_cpu_limit" {
  description = "CPU limit for each Keycloak pod."
  type        = string
  default     = "2"
}

variable "keycloak_memory_limit" {
  description = "Memory limit for each Keycloak pod."
  type        = string
  default     = "2Gi"
}

# ---------------------------------------------------------------------------
# Observability
# ---------------------------------------------------------------------------

variable "observability_enabled" {
  description = "Whether to deploy the observability stack (Prometheus, Grafana, Loki, OTel)."
  type        = bool
  default     = true
}

variable "grafana_admin_password" {
  description = "Initial admin password for Grafana.  Override via tfvars or CI secret."
  type        = string
  default     = "changeme"
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Common Labels
# ---------------------------------------------------------------------------

variable "labels" {
  description = "Additional labels to apply to all resources.  Merged with default labels."
  type        = map(string)
  default     = {}
}
