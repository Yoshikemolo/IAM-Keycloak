# -----------------------------------------------------------------------------
# X-IAM Platform -- QA Environment
# -----------------------------------------------------------------------------
# Pre-production environment that mirrors production architecture at a
# reduced scale.  Single-region only, but with 2 Keycloak replicas to
# validate clustering, HA database disabled but with 14-day backup
# retention, and the full observability stack.
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

# ---------------------------------------------------------------------------
# Providers
# ---------------------------------------------------------------------------

provider "google" {
  project = var.project_id
  region  = var.primary_region
}

provider "google-beta" {
  project = var.project_id
  region  = var.primary_region
}

provider "kubernetes" {
  host                   = "https://${module.gke_primary.cluster_endpoint}"
  cluster_ca_certificate = base64decode(module.gke_primary.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gcloud"
    args = [
      "container", "clusters", "get-credentials",
      module.gke_primary.cluster_name,
      "--region", var.primary_region,
      "--project", var.project_id,
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke_primary.cluster_endpoint}"
    cluster_ca_certificate = base64decode(module.gke_primary.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gcloud"
      args = [
        "container", "clusters", "get-credentials",
        module.gke_primary.cluster_name,
        "--region", var.primary_region,
        "--project", var.project_id,
      ]
    }
  }
}

# ---------------------------------------------------------------------------
# Common Labels
# ---------------------------------------------------------------------------

locals {
  common_labels = merge(var.labels, {
    project     = var.org_name
    environment = var.environment
    managed_by  = "terraform"
  })
}

# ---------------------------------------------------------------------------
# Module: Networking
# ---------------------------------------------------------------------------

module "networking" {
  source = "../../modules/networking"

  project_id           = var.project_id
  environment          = var.environment
  org_name             = var.org_name
  primary_region       = var.primary_region
  secondary_region     = var.secondary_region
  multi_region_enabled = var.multi_region_enabled

  vpc_cidr_primary        = var.vpc_cidr_primary
  vpc_cidr_secondary      = var.vpc_cidr_secondary
  pods_cidr_primary       = var.pods_cidr_primary
  services_cidr_primary   = var.services_cidr_primary
  pods_cidr_secondary     = var.pods_cidr_secondary
  services_cidr_secondary = var.services_cidr_secondary

  labels = local.common_labels
}

# ---------------------------------------------------------------------------
# Module: GKE Cluster (Primary -- Belgium)
# ---------------------------------------------------------------------------

module "gke_primary" {
  source = "../../modules/gke-cluster"

  project_id   = var.project_id
  environment  = var.environment
  org_name     = var.org_name
  region       = var.primary_region
  region_short = "ew1"

  vpc_id              = module.networking.vpc_id
  subnet_id           = module.networking.primary_subnet_id
  pods_range_name     = module.networking.pods_range_name_primary
  services_range_name = module.networking.services_range_name_primary
  private_endpoint    = var.gke_private_endpoint

  release_channel  = "REGULAR"
  binary_auth_mode = "DISABLED"

  system_node_machine_type   = var.system_node_machine_type
  system_node_count          = var.system_node_count
  system_node_min            = var.system_node_min
  system_node_max            = var.system_node_max
  keycloak_node_machine_type = var.keycloak_node_machine_type
  keycloak_node_count        = var.keycloak_node_count
  keycloak_node_min          = var.keycloak_node_min
  keycloak_node_max          = var.keycloak_node_max

  labels = local.common_labels
}

# ---------------------------------------------------------------------------
# Module: Cloud SQL PostgreSQL
# ---------------------------------------------------------------------------

module "postgresql" {
  source = "../../modules/postgresql"

  project_id  = var.project_id
  environment = var.environment
  org_name    = var.org_name
  region      = var.primary_region

  vpc_id                      = module.networking.vpc_id
  private_services_connection = module.networking.private_services_connection

  db_tier               = var.db_tier
  high_availability     = var.db_high_availability
  disk_size_gb          = var.db_disk_size_gb
  deletion_protection   = true
  backup_enabled        = var.db_backup_enabled
  backup_retention_days = var.db_backup_retention_days
  maintenance_day       = var.db_maintenance_day
  maintenance_hour      = var.db_maintenance_hour

  max_connections   = "200"
  shared_buffers_kb = "262144"
  work_mem_kb       = "8192"

  labels = local.common_labels
}

# ---------------------------------------------------------------------------
# Module: Keycloak
# ---------------------------------------------------------------------------

module "keycloak" {
  source = "../../modules/keycloak"

  project_id        = var.project_id
  environment       = var.environment
  org_name          = var.org_name
  keycloak_hostname = var.keycloak_hostname

  keycloak_image_tag = var.keycloak_image_tag
  replicas           = var.keycloak_replicas
  hpa_min            = var.keycloak_hpa_min
  hpa_max            = var.keycloak_hpa_max
  pdb_min_available  = "1"

  db_host     = module.postgresql.private_ip
  db_port     = module.postgresql.db_port
  db_name     = module.postgresql.db_name
  db_user     = module.postgresql.db_user
  db_password = module.postgresql.db_password

  cpu_request    = var.keycloak_cpu_request
  memory_request = var.keycloak_memory_request
  cpu_limit      = var.keycloak_cpu_limit
  memory_limit   = var.keycloak_memory_limit

  log_level = "INFO"

  labels = local.common_labels

  depends_on = [module.gke_primary, module.postgresql]
}

# ---------------------------------------------------------------------------
# Module: Observability
# ---------------------------------------------------------------------------

module "observability" {
  count = var.observability_enabled ? 1 : 0

  source = "../../modules/observability"

  project_id             = var.project_id
  environment            = var.environment
  org_name               = var.org_name
  grafana_admin_password = var.grafana_admin_password

  prometheus_retention    = "15d"
  prometheus_storage_size = "50Gi"
  loki_retention          = "168h"
  loki_storage_size       = "20Gi"
  keycloak_namespace      = module.keycloak.namespace

  labels = local.common_labels

  depends_on = [module.gke_primary]
}
