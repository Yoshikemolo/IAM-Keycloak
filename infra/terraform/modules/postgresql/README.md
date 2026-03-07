# PostgreSQL Module

## Overview

Provisions a Cloud SQL for PostgreSQL 16 instance configured as the backing database for Keycloak.

## Resources Created

| Resource | Description |
|----------|-------------|
| `google_sql_database_instance` | Cloud SQL PostgreSQL 16 instance with private IP |
| `google_sql_database` | Database named "keycloak" |
| `google_sql_user` | User "keycloak" with random password |
| `random_id` | Suffix to avoid name collisions on re-creation |
| `random_password` | Secure password for the database user |

## Security

- Private IP only -- no public endpoint exposed
- Deletion protection enabled by default (disable for dev)
- Query Insights enabled for performance monitoring
- Slow query logging (threshold: 1000 ms)

## Database Flags

| Flag | Default | Purpose |
|------|---------|---------|
| `max_connections` | 200 | Sufficient for ~400 Keycloak users with connection pooling |
| `shared_buffers` | 256 MB | Cache hot data (25% of instance RAM) |
| `work_mem` | 8 MB | Per-operation sort/hash memory |
| `log_min_duration_statement` | 1000 ms | Log slow queries |

## Usage

```hcl
module "postgresql" {
  source = "../../modules/postgresql"

  project_id  = var.project_id
  environment = "prod"
  org_name    = "xiam"
  region      = "europe-west1"

  vpc_id                      = module.networking.vpc_id
  private_services_connection = module.networking.private_services_connection

  db_tier             = "db-custom-4-16384"
  high_availability   = true
  disk_size_gb        = 50
  backup_retention_days = 30
}
```
