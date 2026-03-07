# -----------------------------------------------------------------------------
# Networking Module -- Input Variables
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
  description = "Organisation / platform short name for resource prefixing."
  type        = string
}

variable "primary_region" {
  description = "Primary GCP region."
  type        = string
}

variable "secondary_region" {
  description = "Secondary GCP region for multi-region deployments."
  type        = string
}

variable "multi_region_enabled" {
  description = "Create resources in both regions."
  type        = bool
  default     = false
}

variable "vpc_cidr_primary" {
  description = "CIDR block for the primary subnet."
  type        = string
}

variable "vpc_cidr_secondary" {
  description = "CIDR block for the secondary subnet."
  type        = string
}

variable "pods_cidr_primary" {
  description = "Secondary range CIDR for GKE pods (primary region)."
  type        = string
}

variable "services_cidr_primary" {
  description = "Secondary range CIDR for GKE services (primary region)."
  type        = string
}

variable "pods_cidr_secondary" {
  description = "Secondary range CIDR for GKE pods (secondary region)."
  type        = string
}

variable "services_cidr_secondary" {
  description = "Secondary range CIDR for GKE services (secondary region)."
  type        = string
}

variable "labels" {
  description = "Labels to apply to all resources."
  type        = map(string)
  default     = {}
}
