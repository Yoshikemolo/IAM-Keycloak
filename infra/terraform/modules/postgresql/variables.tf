# -----------------------------------------------------------------------------
# PostgreSQL Module -- Input Variables
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, qa, prod)."
  type        = string
}

variable "org_name" {
  description = "Organisation / platform short name."
  type        = string
}

variable "region" {
  description = "GCP region for the Cloud SQL instance."
  type        = string
}

# ---- Networking ----

variable "vpc_id" {
  description = "Self-link of the VPC network."
  type        = string
}

variable "private_services_connection" {
  description = "ID of the google_service_networking_connection resource (used for depends_on)."
  type        = string
}

# ---- Instance Configuration ----

variable "db_tier" {
  description = "Cloud SQL machine tier."
  type        = string
  default     = "db-custom-2-8192"
}

variable "high_availability" {
  description = "Enable regional high-availability (REGIONAL availability_type)."
  type        = bool
  default     = false
}

variable "disk_size_gb" {
  description = "Initial disk size in GB."
  type        = number
  default     = 20
}

variable "deletion_protection" {
  description = "Prevent accidental instance deletion via Terraform."
  type        = bool
  default     = true
}

# ---- Backup ----

variable "backup_enabled" {
  description = "Enable automated backups."
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of automated backups to retain."
  type        = number
  default     = 7
}

# ---- Maintenance ----

variable "maintenance_day" {
  description = "Preferred maintenance day (1=Mon .. 7=Sun)."
  type        = number
  default     = 7
}

variable "maintenance_hour" {
  description = "Preferred maintenance hour (UTC, 0-23)."
  type        = number
  default     = 3
}

# ---- Database Flags ----

variable "max_connections" {
  description = "PostgreSQL max_connections flag value."
  type        = string
  default     = "200"
}

variable "shared_buffers_kb" {
  description = "PostgreSQL shared_buffers in KB (flag value as string)."
  type        = string
  default     = "262144"
}

variable "work_mem_kb" {
  description = "PostgreSQL work_mem in KB (flag value as string)."
  type        = string
  default     = "8192"
}

# ---- Labels ----

variable "labels" {
  description = "Labels to apply to all resources."
  type        = map(string)
  default     = {}
}
