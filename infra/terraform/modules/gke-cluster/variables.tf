# -----------------------------------------------------------------------------
# GKE Cluster Module -- Input Variables
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
  description = "GCP region where the cluster will be created."
  type        = string
}

variable "region_short" {
  description = "Short label for the region, used in resource naming (e.g. ew1, esw1)."
  type        = string
}

# ---- Networking ----

variable "vpc_id" {
  description = "Self-link of the VPC network."
  type        = string
}

variable "subnet_id" {
  description = "Self-link of the subnet."
  type        = string
}

variable "pods_range_name" {
  description = "Name of the secondary IP range for pods."
  type        = string
}

variable "services_range_name" {
  description = "Name of the secondary IP range for services."
  type        = string
}

variable "master_cidr" {
  description = "CIDR block for the GKE control-plane VPC peering (/28 required)."
  type        = string
  default     = "172.16.0.0/28"

  validation {
    condition     = can(cidrhost(var.master_cidr, 0))
    error_message = "master_cidr must be a valid CIDR block."
  }
}

variable "private_endpoint" {
  description = "If true, the control plane is only accessible from private networks."
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "List of CIDR blocks allowed to reach the GKE control plane."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [
    {
      cidr_block   = "10.0.0.0/8"
      display_name = "Internal VPC"
    }
  ]
}

# ---- Cluster Configuration ----

variable "release_channel" {
  description = "GKE release channel (RAPID, REGULAR, STABLE)."
  type        = string
  default     = "REGULAR"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be one of: RAPID, REGULAR, STABLE."
  }
}

variable "binary_auth_mode" {
  description = "Binary Authorization evaluation mode (DISABLED, PROJECT_SINGLETON_POLICY_ENFORCE)."
  type        = string
  default     = "DISABLED"
}

# ---- System Node Pool ----

variable "system_node_machine_type" {
  description = "Machine type for the system node pool."
  type        = string
  default     = "e2-standard-2"
}

variable "system_node_count" {
  description = "Initial node count for the system pool (per zone)."
  type        = number
  default     = 1
}

variable "system_node_min" {
  description = "Minimum nodes for system pool autoscaler."
  type        = number
  default     = 1
}

variable "system_node_max" {
  description = "Maximum nodes for system pool autoscaler."
  type        = number
  default     = 3
}

# ---- Keycloak Node Pool ----

variable "keycloak_node_machine_type" {
  description = "Machine type for the Keycloak node pool."
  type        = string
  default     = "e2-standard-4"
}

variable "keycloak_node_count" {
  description = "Initial node count for the Keycloak pool (per zone)."
  type        = number
  default     = 1
}

variable "keycloak_node_min" {
  description = "Minimum nodes for Keycloak pool autoscaler."
  type        = number
  default     = 1
}

variable "keycloak_node_max" {
  description = "Maximum nodes for Keycloak pool autoscaler."
  type        = number
  default     = 3
}

# ---- Labels ----

variable "labels" {
  description = "Labels to apply to all resources."
  type        = map(string)
  default     = {}
}
