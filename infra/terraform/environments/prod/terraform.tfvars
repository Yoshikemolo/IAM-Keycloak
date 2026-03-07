# -----------------------------------------------------------------------------
# X-IAM Platform -- Prod Environment -- Variable Values
# -----------------------------------------------------------------------------
# Full HA multi-region production deployment.
# IMPORTANT: grafana_admin_password must be provided via CI secret or
# TF_VAR_grafana_admin_password environment variable -- never commit it here.
# Override project_id with your own GCP project.
# -----------------------------------------------------------------------------

# ---- Project ----
project_id  = "xiam-prod-project"
environment = "prod"
org_name    = "xiam"

# ---- Regions ----
primary_region       = "europe-west1"
secondary_region     = "europe-southwest1"
multi_region_enabled = true

# ---- GKE ----
system_node_machine_type   = "e2-standard-4"
system_node_count          = 2
system_node_min            = 2
system_node_max            = 5
keycloak_node_machine_type = "e2-standard-8"
keycloak_node_count        = 2
keycloak_node_min          = 2
keycloak_node_max          = 5
gke_private_endpoint       = true

# ---- Cloud SQL ----
db_tier                  = "db-custom-4-16384"
db_high_availability     = true
db_disk_size_gb          = 50
db_backup_enabled        = true
db_backup_retention_days = 30

# ---- Keycloak ----
keycloak_replicas       = 3
keycloak_image_tag      = "26.4.2"
keycloak_hostname       = "iam.xiam.io"
keycloak_hpa_min        = 2
keycloak_hpa_max        = 10
keycloak_cpu_request    = "1"
keycloak_memory_request = "2Gi"
keycloak_cpu_limit      = "4"
keycloak_memory_limit   = "4Gi"

# ---- Observability ----
observability_enabled = true
# grafana_admin_password = <set via TF_VAR_grafana_admin_password>
