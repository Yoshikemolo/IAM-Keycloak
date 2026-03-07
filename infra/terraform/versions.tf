# -----------------------------------------------------------------------------
# X-IAM Platform -- Terraform Version and Provider Constraints
# -----------------------------------------------------------------------------
# This file pins the Terraform CLI version and every provider used across the
# root module.  All child modules inherit these constraints unless they declare
# their own (which they intentionally do not, to keep a single source of truth).
#
# Provider matrix
#   google        -- standard GCP resources (VPC, GKE, Cloud SQL, IAM ...)
#   google-beta   -- beta-channel GKE features (Binary Authorization, etc.)
#   helm          -- Keycloak and observability stack Helm releases
#   kubernetes    -- Namespaces, ConfigMaps, and other raw K8s objects
#   random        -- Deterministic random values (passwords, suffixes)
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
