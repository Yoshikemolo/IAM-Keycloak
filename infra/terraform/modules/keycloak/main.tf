# -----------------------------------------------------------------------------
# X-IAM Platform -- Keycloak Module
# -----------------------------------------------------------------------------
# Deploys Keycloak on GKE using the Bitnami Helm chart.  This module handles:
#
#   1. Kubernetes namespace creation
#   2. Kubernetes service account with Workload Identity binding
#   3. GCP IAM service account for Workload Identity
#   4. Kubernetes Secret for database credentials
#   5. Helm release (bitnami/keycloak) with production-ready values
#   6. Horizontal Pod Autoscaler (HPA)
#   7. Pod Disruption Budget (PDB)
#
# Environment variables passed to Keycloak via Helm values:
#   KC_DB, KC_DB_URL, KC_DB_USERNAME, KC_DB_PASSWORD,
#   KC_HOSTNAME, KC_PROXY_HEADERS, KC_HEALTH_ENABLED, KC_METRICS_ENABLED
# -----------------------------------------------------------------------------

locals {
  labels = merge(var.labels, {
    project     = var.org_name
    environment = var.environment
    managed_by  = "terraform"
    module      = "keycloak"
  })

  prefix    = "${var.org_name}-${var.environment}"
  namespace = "${local.prefix}-keycloak"

  # JDBC connection URL for PostgreSQL.
  db_jdbc_url = "jdbc:postgresql://${var.db_host}:${var.db_port}/${var.db_name}"
}

# ---------------------------------------------------------------------------
# Kubernetes Namespace
# ---------------------------------------------------------------------------

resource "kubernetes_namespace" "keycloak" {
  metadata {
    name   = local.namespace
    labels = local.labels
  }
}

# ---------------------------------------------------------------------------
# GCP Service Account (Workload Identity)
# ---------------------------------------------------------------------------
# A dedicated GCP SA allows Keycloak pods to authenticate to GCP services
# (Cloud SQL, Secret Manager, etc.) without static keys.

resource "google_service_account" "keycloak" {
  project    = var.project_id
  account_id = "${local.prefix}-kc-sa"

  display_name = "Keycloak Workload Identity SA (${var.environment})"
  description  = "Service account bound to the Keycloak Kubernetes SA via Workload Identity."
}

# Bind the GCP SA to the Kubernetes SA via Workload Identity.
resource "google_service_account_iam_member" "workload_identity" {
  service_account_id = google_service_account.keycloak.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${local.prefix}-keycloak]"
}

# Grant the SA access to Cloud SQL (for connection via private IP).
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.keycloak.email}"
}

# ---------------------------------------------------------------------------
# Kubernetes Secret -- Database Credentials
# ---------------------------------------------------------------------------

resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "${local.prefix}-db-credentials"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
    labels    = local.labels
  }

  data = {
    KC_DB_URL      = local.db_jdbc_url
    KC_DB_USERNAME = var.db_user
    KC_DB_PASSWORD = var.db_password
  }

  type = "Opaque"
}

# ---------------------------------------------------------------------------
# Helm Release -- Bitnami Keycloak
# ---------------------------------------------------------------------------

resource "helm_release" "keycloak" {
  name       = "keycloak"
  namespace  = kubernetes_namespace.keycloak.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "keycloak"
  version    = var.helm_chart_version

  timeout         = 600
  atomic          = true
  cleanup_on_fail = true
  wait            = true

  # ---- Image ----
  set {
    name  = "image.tag"
    value = var.keycloak_image_tag
  }

  # ---- Replicas ----
  set {
    name  = "replicaCount"
    value = var.replicas
  }

  # ---- Service Account with Workload Identity annotation ----
  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "${local.prefix}-keycloak"
  }

  set {
    name  = "serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account"
    value = google_service_account.keycloak.email
  }

  # ---- Node affinity: schedule on keycloak-tainted nodes ----
  set {
    name  = "tolerations[0].key"
    value = "workload"
  }

  set {
    name  = "tolerations[0].value"
    value = "keycloak"
  }

  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Equal"
  }

  set {
    name  = "nodeSelector.node_pool"
    value = "keycloak"
  }

  # ---- Database Configuration ----
  set {
    name  = "postgresql.enabled"
    value = "false"
  }

  set {
    name  = "externalDatabase.host"
    value = var.db_host
  }

  set {
    name  = "externalDatabase.port"
    value = var.db_port
  }

  set {
    name  = "externalDatabase.database"
    value = var.db_name
  }

  set {
    name  = "externalDatabase.existingSecret"
    value = kubernetes_secret.db_credentials.metadata[0].name
  }

  set {
    name  = "externalDatabase.existingSecretPasswordKey"
    value = "KC_DB_PASSWORD"
  }

  set {
    name  = "externalDatabase.existingSecretUsernameKey"
    value = "KC_DB_USERNAME"
  }

  # ---- Keycloak Configuration via Environment Variables ----
  set {
    name  = "extraEnvVars[0].name"
    value = "KC_DB"
  }

  set {
    name  = "extraEnvVars[0].value"
    value = "postgres"
  }

  set {
    name  = "extraEnvVars[1].name"
    value = "KC_HOSTNAME"
  }

  set {
    name  = "extraEnvVars[1].value"
    value = var.keycloak_hostname
  }

  set {
    name  = "extraEnvVars[2].name"
    value = "KC_PROXY_HEADERS"
    }

  set {
    name  = "extraEnvVars[2].value"
    value = "xforwarded"
  }

  set {
    name  = "extraEnvVars[3].name"
    value = "KC_HEALTH_ENABLED"
  }

  set {
    name  = "extraEnvVars[3].value"
    value = "true"
  }

  set {
    name  = "extraEnvVars[4].name"
    value = "KC_METRICS_ENABLED"
  }

  set {
    name  = "extraEnvVars[4].value"
    value = "true"
  }

  set {
    name  = "extraEnvVars[5].name"
    value = "KC_HTTP_ENABLED"
  }

  set {
    name  = "extraEnvVars[5].value"
    value = "true"
  }

  set {
    name  = "extraEnvVars[6].name"
    value = "KC_LOG_LEVEL"
  }

  set {
    name  = "extraEnvVars[6].value"
    value = var.log_level
  }

  set {
    name  = "extraEnvVars[7].name"
    value = "KC_CACHE"
  }

  set {
    name  = "extraEnvVars[7].value"
    value = "ispn"
  }

  set {
    name  = "extraEnvVars[8].name"
    value = "KC_CACHE_STACK"
  }

  set {
    name  = "extraEnvVars[8].value"
    value = "kubernetes"
  }

  # ---- Resource Requests and Limits ----
  set {
    name  = "resources.requests.cpu"
    value = var.cpu_request
  }

  set {
    name  = "resources.requests.memory"
    value = var.memory_request
  }

  set {
    name  = "resources.limits.cpu"
    value = var.cpu_limit
  }

  set {
    name  = "resources.limits.memory"
    value = var.memory_limit
  }

  # ---- Health Checks ----
  set {
    name  = "livenessProbe.enabled"
    value = "true"
  }

  set {
    name  = "readinessProbe.enabled"
    value = "true"
  }

  set {
    name  = "startupProbe.enabled"
    value = "true"
  }

  set {
    name  = "startupProbe.initialDelaySeconds"
    value = "30"
  }

  set {
    name  = "startupProbe.periodSeconds"
    value = "10"
  }

  set {
    name  = "startupProbe.failureThreshold"
    value = "30"
  }

  # ---- Ingress ----
  set {
    name  = "ingress.enabled"
    value = var.ingress_enabled ? "true" : "false"
  }

  set {
    name  = "ingress.ingressClassName"
    value = "gce"
  }

  set {
    name  = "ingress.hostname"
    value = var.keycloak_hostname
  }

  set {
    name  = "ingress.annotations.kubernetes\\.io/ingress\\.global-static-ip-name"
    value = "${local.prefix}-keycloak-ip"
  }

  set {
    name  = "ingress.tls"
    value = "true"
  }

  # ---- Pod Labels ----
  set {
    name  = "commonLabels.project"
    value = var.org_name
  }

  set {
    name  = "commonLabels.environment"
    value = var.environment
  }

  set {
    name  = "commonLabels.managed_by"
    value = "terraform"
  }

  # ---- Pod Anti-Affinity (spread across nodes) ----
  set {
    name  = "podAntiAffinityPreset"
    value = "soft"
  }

  depends_on = [
    kubernetes_namespace.keycloak,
    kubernetes_secret.db_credentials,
  ]
}

# ---------------------------------------------------------------------------
# Horizontal Pod Autoscaler (HPA)
# ---------------------------------------------------------------------------

resource "kubernetes_horizontal_pod_autoscaler_v2" "keycloak" {
  metadata {
    name      = "${local.prefix}-keycloak-hpa"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
    labels    = local.labels
  }

  spec {
    min_replicas = var.hpa_min
    max_replicas = var.hpa_max

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "keycloak"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 70
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = 80
        }
      }
    }

    behavior {
      scale_up {
        stabilization_window_seconds = 60
        select_policy                = "Max"
        policy {
          type           = "Pods"
          value          = 2
          period_seconds = 60
        }
      }

      scale_down {
        stabilization_window_seconds = 300
        select_policy                = "Min"
        policy {
          type           = "Pods"
          value          = 1
          period_seconds = 120
        }
      }
    }
  }

  depends_on = [helm_release.keycloak]
}

# ---------------------------------------------------------------------------
# Pod Disruption Budget (PDB)
# ---------------------------------------------------------------------------
# Ensures at least one Keycloak pod is always available during voluntary
# disruptions (node drain, rolling update, cluster upgrade).

resource "kubernetes_pod_disruption_budget_v1" "keycloak" {
  metadata {
    name      = "${local.prefix}-keycloak-pdb"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
    labels    = local.labels
  }

  spec {
    min_available = var.pdb_min_available

    selector {
      match_labels = {
        "app.kubernetes.io/name"     = "keycloak"
        "app.kubernetes.io/instance" = "keycloak"
      }
    }
  }

  depends_on = [helm_release.keycloak]
}
