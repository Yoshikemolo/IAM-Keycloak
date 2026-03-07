# -----------------------------------------------------------------------------
# X-IAM Platform -- Cloud SQL PostgreSQL Module
# -----------------------------------------------------------------------------
# Provisions a Cloud SQL for PostgreSQL 16 instance configured for Keycloak:
#
#   - Private IP only (no public IP) via Private Service Access
#   - Automated daily backups with configurable retention
#   - Point-in-time recovery (PITR) enabled
#   - High Availability (regional) for production
#   - Maintenance window on Sundays at 03:00 UTC by default
#   - Database flags tuned for Keycloak workloads (~400 users)
#   - Deletion protection enabled for non-dev environments
#   - Random suffix to avoid name collisions on re-creation
#
# The module creates:
#   1. The Cloud SQL instance
#   2. A database named "keycloak"
#   3. A database user "keycloak" with a randomly generated password
#   4. A Kubernetes Secret in the target namespace (for Keycloak pods)
# -----------------------------------------------------------------------------

locals {
  labels = merge(var.labels, {
    project     = var.org_name
    environment = var.environment
    managed_by  = "terraform"
    module      = "postgresql"
  })

  prefix = "${var.org_name}-${var.environment}"
}

# ---------------------------------------------------------------------------
# Random suffix -- Cloud SQL instance names are globally unique and cannot be
# reused for up to a week after deletion.  A random suffix avoids conflicts.
# ---------------------------------------------------------------------------

resource "random_id" "db_suffix" {
  byte_length = 4
}

# ---------------------------------------------------------------------------
# Cloud SQL Instance
# ---------------------------------------------------------------------------

resource "google_sql_database_instance" "keycloak" {
  project = var.project_id
  name    = "${local.prefix}-pg-${random_id.db_suffix.hex}"
  region  = var.region

  database_version = "POSTGRES_16"

  # Prevent accidental deletion in non-dev environments.
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.db_tier
    availability_type = var.high_availability ? "REGIONAL" : "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = var.disk_size_gb
    disk_autoresize   = true

    # ---- Private IP only ----
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.vpc_id
      enable_private_path_for_google_cloud_services = true
    }

    # ---- Backup Configuration ----
    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = "02:00"
      location                       = var.region
      point_in_time_recovery_enabled = var.backup_enabled

      backup_retention_settings {
        retained_backups = var.backup_retention_days
        retention_unit   = "COUNT"
      }
    }

    # ---- Maintenance Window ----
    maintenance_window {
      day          = var.maintenance_day
      hour         = var.maintenance_hour
      update_track = "stable"
    }

    # ---- Database Flags ----
    # Tuned for Keycloak with ~400 concurrent users and session management.
    database_flags {
      name  = "max_connections"
      value = var.max_connections
    }

    database_flags {
      name  = "shared_buffers"
      value = var.shared_buffers_kb
    }

    database_flags {
      name  = "work_mem"
      value = var.work_mem_kb
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "1000"
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }

    # ---- Insights (Query Statistics) ----
    insights_config {
      query_insights_enabled  = true
      query_plans_per_minute  = 5
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    user_labels = local.labels
  }

  # Ensure the private services connection exists before creating the instance.
  depends_on = [var.private_services_connection]
}

# ---------------------------------------------------------------------------
# Database
# ---------------------------------------------------------------------------

resource "google_sql_database" "keycloak" {
  project  = var.project_id
  instance = google_sql_database_instance.keycloak.name
  name     = "keycloak"

  charset   = "UTF8"
  collation = "en_US.UTF8"
}

# ---------------------------------------------------------------------------
# Database User
# ---------------------------------------------------------------------------

resource "random_password" "db_password" {
  length  = 32
  special = true

  # Avoid characters that cause escaping issues in JDBC URLs.
  override_special = "!#%&*+-=?^_"
}

resource "google_sql_user" "keycloak" {
  project  = var.project_id
  instance = google_sql_database_instance.keycloak.name

  name     = "keycloak"
  password = random_password.db_password.result

  deletion_policy = "ABANDON"
}
