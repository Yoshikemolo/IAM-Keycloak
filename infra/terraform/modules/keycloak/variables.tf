# -----------------------------------------------------------------------------
# Keycloak Module -- Input Variables
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

# ---- Helm ----

variable "helm_chart_version" {
  description = "Version of the bitnami/keycloak Helm chart."
  type        = string
  default     = "24.4.1"
}

variable "keycloak_image_tag" {
  description = "Keycloak container image tag."
  type        = string
  default     = "26.4.2"
}

# ---- Replicas and Scaling ----

variable "replicas" {
  description = "Number of Keycloak pod replicas."
  type        = number
  default     = 1
}

variable "hpa_min" {
  description = "HPA minimum replica count."
  type        = number
  default     = 1
}

variable "hpa_max" {
  description = "HPA maximum replica count."
  type        = number
  default     = 3
}

variable "pdb_min_available" {
  description = "Minimum available pods enforced by the PDB."
  type        = string
  default     = "1"
}

# ---- Hostname ----

variable "keycloak_hostname" {
  description = "Public hostname for Keycloak (KC_HOSTNAME)."
  type        = string
}

variable "ingress_enabled" {
  description = "Whether to create an Ingress resource for Keycloak."
  type        = bool
  default     = true
}

# ---- Database ----

variable "db_host" {
  description = "Cloud SQL private IP address."
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "PostgreSQL port."
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Database name."
  type        = string
  default     = "keycloak"
}

variable "db_user" {
  description = "Database username."
  type        = string
  default     = "keycloak"
}

variable "db_password" {
  description = "Database password."
  type        = string
  sensitive   = true
}

# ---- Resources ----

variable "cpu_request" {
  description = "CPU request for each Keycloak pod."
  type        = string
  default     = "500m"
}

variable "memory_request" {
  description = "Memory request for each Keycloak pod."
  type        = string
  default     = "1Gi"
}

variable "cpu_limit" {
  description = "CPU limit for each Keycloak pod."
  type        = string
  default     = "2"
}

variable "memory_limit" {
  description = "Memory limit for each Keycloak pod."
  type        = string
  default     = "2Gi"
}

# ---- Logging ----

variable "log_level" {
  description = "Keycloak log level (INFO, DEBUG, WARN, ERROR)."
  type        = string
  default     = "INFO"

  validation {
    condition     = contains(["ALL", "DEBUG", "ERROR", "FATAL", "INFO", "OFF", "TRACE", "WARN"], var.log_level)
    error_message = "log_level must be a valid Keycloak log level."
  }
}

# ---- Labels ----

variable "labels" {
  description = "Labels to apply to all resources."
  type        = map(string)
  default     = {}
}
