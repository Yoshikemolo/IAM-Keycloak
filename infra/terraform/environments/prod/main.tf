# -----------------------------------------------------------------------------
# X-IAM Platform -- Prod Environment
# -----------------------------------------------------------------------------
# Full production deployment with multi-region high availability:
#
#   - 2 GKE clusters: europe-west1 (Belgium) + europe-southwest1 (Madrid)
#   - Large node pools (e2-standard-8 for Keycloak)
#   - Cloud SQL: REGIONAL HA, 50 GB SSD, 30-day backup, PITR
#   - Keycloak: 3 replicas, HPA min=2 max=10, PDB minAvailable=1
#   - Binary Authorization in audit mode
#   - Private GKE endpoint (control plane not internet-accessible)
#   - Full observability with 30-day Prometheus retention
#   - Deletion protection on all stateful resources
#
# Multi-region strategy:
#   Both clusters share the same VPC.  A Global External HTTPS Load Balancer
#   (configured outside Terraform or via a separate module) distributes
#   traffic between regions.  Cloud SQL read replicas in the secondary
#   region should be added if cross-region read latency is a concern.
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

# Primary cluster providers (used for Keycloak and observability deployment).
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
# Creates VPC, subnets in both regions, Cloud NAT for each, firewall rules,
# and Private Service Access for Cloud SQL.

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
# Module: GKE Cluster -- Primary (Belgium, europe-west1)
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
  master_cidr         = "172.16.0.0/28"

  release_channel  = "STABLE"
  binary_auth_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"

  master_authorized_networks = [
    {
      cidr_block   = var.vpc_cidr_primary
      display_name = "Primary subnet"
    },
    {
      cidr_block   = var.vpc_cidr_secondary
      display_name = "Secondary subnet"
    },
  ]

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
# Module: GKE Cluster -- Secondary (Madrid, europe-southwest1)
# ---------------------------------------------------------------------------
# Only created when multi_region_enabled = true.

module "gke_secondary" {
  count  = var.multi_region_enabled ? 1 : 0
  source = "../../modules/gke-cluster"

  project_id   = var.project_id
  environment  = var.environment
  org_name     = var.org_name
  region       = var.secondary_region
  region_short = "esw1"

  vpc_id              = module.networking.vpc_id
  subnet_id           = module.networking.secondary_subnet_id
  pods_range_name     = module.networking.pods_range_name_secondary
  services_range_name = module.networking.services_range_name_secondary
  private_endpoint    = var.gke_private_endpoint
  master_cidr         = "172.16.1.0/28"

  release_channel  = "STABLE"
  binary_auth_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"

  master_authorized_networks = [
    {
      cidr_block   = var.vpc_cidr_primary
      display_name = "Primary subnet"
    },
    {
      cidr_block   = var.vpc_cidr_secondary
      display_name = "Secondary subnet"
    },
  ]

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
# Single regional HA instance in the primary region.  For true multi-region
# database resilience, a Cloud SQL read replica in europe-southwest1 and/or
# Cross-Region Replica should be configured separately.

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

  # Production-tuned database flags for ~400 concurrent users.
  max_connections   = "400"
  shared_buffers_kb = "524288"
  work_mem_kb       = "16384"

  labels = local.common_labels
}

# ---------------------------------------------------------------------------
# Module: Keycloak
# ---------------------------------------------------------------------------
# Deployed to the primary cluster.  For active-active multi-region, a second
# Keycloak module instance targeting the secondary cluster would be needed,
# along with Infinispan cross-site replication configuration.

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

  prometheus_retention    = "30d"
  prometheus_storage_size = "100Gi"
  alertmanager_enabled    = true
  loki_retention          = "720h"
  loki_storage_size       = "50Gi"
  otel_replicas           = 2
  keycloak_namespace      = module.keycloak.namespace

  labels = local.common_labels

  depends_on = [module.gke_primary]
}
