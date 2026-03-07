# -----------------------------------------------------------------------------
# X-IAM Platform -- QA Environment -- Variable Values
# -----------------------------------------------------------------------------
# Pre-production environment: mirrors prod architecture at reduced scale.
# Override project_id with your own GCP project.
# -----------------------------------------------------------------------------

# ---- Project ----
project_id  = "xiam-qa-project"
environment = "qa"
org_name    = "xiam"

# ---- Regions ----
primary_region       = "europe-west1"
secondary_region     = "europe-southwest1"
multi_region_enabled = false

# ---- GKE ----
system_node_machine_type   = "e2-standard-4"
system_node_count          = 1
system_node_min            = 1
system_node_max            = 3
keycloak_node_machine_type = "e2-standard-4"
keycloak_node_count        = 1
keycloak_node_min          = 1
keycloak_node_max          = 3
gke_private_endpoint       = false

# ---- Cloud SQL ----
db_tier                  = "db-custom-2-8192"
db_high_availability     = false
db_disk_size_gb          = 20
db_backup_enabled        = true
db_backup_retention_days = 14

# ---- Keycloak ----
keycloak_replicas       = 2
keycloak_image_tag      = "26.4.2"
keycloak_hostname       = "iam-qa.xiam.dev"
keycloak_hpa_min        = 2
keycloak_hpa_max        = 5
keycloak_cpu_request    = "500m"
keycloak_memory_request = "1Gi"
keycloak_cpu_limit      = "2"
keycloak_memory_limit   = "2Gi"

# ---- Observability ----
observability_enabled = true
