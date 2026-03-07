# -----------------------------------------------------------------------------
# X-IAM Platform -- Dev Environment -- Variable Values
# -----------------------------------------------------------------------------
# Cost-optimised single-region development environment.
# Override project_id with your own GCP project.
# -----------------------------------------------------------------------------

# ---- Project ----
project_id  = "xiam-dev-project"
environment = "dev"
org_name    = "xiam"

# ---- Regions ----
primary_region       = "europe-west1"
secondary_region     = "europe-southwest1"
multi_region_enabled = false

# ---- GKE ----
system_node_machine_type   = "e2-standard-2"
system_node_count          = 1
system_node_min            = 1
system_node_max            = 2
keycloak_node_machine_type = "e2-standard-2"
keycloak_node_count        = 1
keycloak_node_min          = 1
keycloak_node_max          = 2
gke_private_endpoint       = false

# ---- Cloud SQL ----
db_tier                  = "db-custom-1-3840"
db_high_availability     = false
db_disk_size_gb          = 10
db_backup_enabled        = true
db_backup_retention_days = 7

# ---- Keycloak ----
keycloak_replicas      = 1
keycloak_image_tag     = "26.4.2"
keycloak_hostname      = "iam-dev.xiam.dev"
keycloak_hpa_min       = 1
keycloak_hpa_max       = 3
keycloak_cpu_request   = "250m"
keycloak_memory_request = "512Mi"
keycloak_cpu_limit     = "1"
keycloak_memory_limit  = "1Gi"

# ---- Observability ----
observability_enabled = true
