# -----------------------------------------------------------------------------
# X-IAM Platform -- GKE Cluster Module
# -----------------------------------------------------------------------------
# Provisions a private GKE cluster with two managed node pools:
#
#   1. "system"   -- General-purpose pool for infrastructure workloads
#                    (Ingress controllers, cert-manager, observability, etc.)
#   2. "keycloak" -- Dedicated pool with taints so that only Keycloak pods
#                    (which tolerate the taint) are scheduled here, ensuring
#                    predictable resource allocation for the IAM service.
#
# Security features enabled by default:
#   - Private nodes (no external IPs on worker nodes)
#   - Shielded nodes (Secure Boot + Integrity Monitoring)
#   - Workload Identity (GKE metadata server replaces node SA keys)
#   - Binary Authorization (audit mode by default, enforce in prod)
#   - Network Policy via Dataplane V2 (Cilium)
#   - Node auto-upgrade and auto-repair
# -----------------------------------------------------------------------------

locals {
  labels = merge(var.labels, {
    project     = var.org_name
    environment = var.environment
    managed_by  = "terraform"
    module      = "gke-cluster"
  })

  prefix = "${var.org_name}-${var.environment}"
}

# ---------------------------------------------------------------------------
# GKE Cluster (control plane)
# ---------------------------------------------------------------------------

resource "google_container_cluster" "cluster" {
  provider = google-beta
  project  = var.project_id
  name     = "${local.prefix}-gke-${var.region_short}"
  location = var.region

  # We manage node pools as separate resources for independent lifecycle control.
  # The default pool is removed immediately after cluster creation.
  remove_default_node_pool = true
  initial_node_count       = 1

  # ---- Networking ----
  network    = var.vpc_id
  subnetwork = var.subnet_id

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Dataplane V2 (Cilium) provides built-in network policy enforcement,
  # eBPF-based visibility, and removes the need for Calico.
  datapath_provider = "ADVANCED_DATAPATH"

  # ---- Private Cluster ----
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.private_endpoint
    master_ipv4_cidr_block  = var.master_cidr
  }

  # Allow the full subnet and pod ranges to reach the control plane.
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  # ---- Workload Identity ----
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # ---- Binary Authorization ----
  binary_authorization {
    evaluation_mode = var.binary_auth_mode
  }

  # ---- Logging and Monitoring ----
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "DEPLOYMENT", "HPA", "POD", "DAEMONSET", "STATEFULSET"]

    managed_prometheus {
      enabled = true
    }
  }

  # ---- Maintenance Window ----
  maintenance_policy {
    recurring_window {
      # Sunday 02:00 - 06:00 UTC -- low-traffic window.
      start_time = "2024-01-07T02:00:00Z"
      end_time   = "2024-01-07T06:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SU"
    }
  }

  # ---- Add-ons ----
  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    gce_persistent_disk_csi_driver_config {
      enabled = true
    }

    dns_cache_config {
      enabled = true
    }
  }

  # ---- Release Channel ----
  release_channel {
    channel = var.release_channel
  }

  # ---- Security Posture ----
  security_posture_config {
    mode               = "BASIC"
    vulnerability_mode = "VULNERABILITY_BASIC"
  }

  resource_labels = local.labels

  # Lifecycle: ignore changes to initial_node_count after creation.
  lifecycle {
    ignore_changes = [initial_node_count]
  }
}

# ---------------------------------------------------------------------------
# Node Pool: system
# ---------------------------------------------------------------------------
# Hosts infrastructure workloads: ingress controllers, cert-manager,
# external-dns, observability stack, and any other non-Keycloak services.

resource "google_container_node_pool" "system" {
  provider = google-beta
  project  = var.project_id
  name     = "${local.prefix}-system"
  location = var.region
  cluster  = google_container_cluster.cluster.name

  initial_node_count = var.system_node_count

  autoscaling {
    min_node_count = var.system_node_min
    max_node_count = var.system_node_max
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
    strategy        = "SURGE"
  }

  node_config {
    machine_type = var.system_node_machine_type
    disk_type    = "pd-ssd"
    disk_size_gb = 50

    # Use the default Compute Engine service account with minimal scopes;
    # workload identity provides per-pod credentials.
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    # Shielded instance options for boot integrity.
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # Workload identity mode.
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = merge(local.labels, {
      node_pool = "system"
    })

    # Metadata to disable legacy metadata endpoints.
    metadata = {
      disable-legacy-endpoints = "true"
    }

    tags = ["${local.prefix}-system-node"]
  }
}

# ---------------------------------------------------------------------------
# Node Pool: keycloak
# ---------------------------------------------------------------------------
# Dedicated pool for Keycloak pods.  A taint prevents other workloads from
# being scheduled on these nodes; only pods with a matching toleration
# (defined in the Keycloak Helm values) will run here.

resource "google_container_node_pool" "keycloak" {
  provider = google-beta
  project  = var.project_id
  name     = "${local.prefix}-keycloak"
  location = var.region
  cluster  = google_container_cluster.cluster.name

  initial_node_count = var.keycloak_node_count

  autoscaling {
    min_node_count = var.keycloak_node_min
    max_node_count = var.keycloak_node_max
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
    strategy        = "SURGE"
  }

  node_config {
    machine_type = var.keycloak_node_machine_type
    disk_type    = "pd-ssd"
    disk_size_gb = 50

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Taint: only pods that tolerate "workload=keycloak:NoSchedule" land here.
    taint {
      key    = "workload"
      value  = "keycloak"
      effect = "NO_SCHEDULE"
    }

    labels = merge(local.labels, {
      node_pool = "keycloak"
    })

    metadata = {
      disable-legacy-endpoints = "true"
    }

    tags = ["${local.prefix}-keycloak-node"]
  }
}
