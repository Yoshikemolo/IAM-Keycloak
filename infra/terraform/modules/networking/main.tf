# -----------------------------------------------------------------------------
# X-IAM Platform -- Networking Module
# -----------------------------------------------------------------------------
# Creates the foundational network layer for the IAM platform:
#
#   - VPC with custom-mode subnets (no auto-created subnets)
#   - Primary subnet in europe-west1 (Belgium) with secondary ranges for
#     GKE pods and services
#   - Optional secondary subnet in europe-southwest1 (Madrid) for
#     multi-region production deployments
#   - Cloud NAT gateways for each region (private nodes need egress)
#   - Firewall rules: health checks, IAP SSH, internal pod-to-pod
#   - Private Service Access for Cloud SQL private IP connectivity
#
# All resources are labelled with project, environment, and managed_by tags.
# -----------------------------------------------------------------------------

locals {
  # Standard labels applied to every resource in this module.
  labels = merge(var.labels, {
    project     = var.org_name
    environment = var.environment
    managed_by  = "terraform"
    module      = "networking"
  })

  # Derive resource name prefix to ensure uniqueness.
  prefix = "${var.org_name}-${var.environment}"
}

# ---------------------------------------------------------------------------
# VPC Network
# ---------------------------------------------------------------------------

resource "google_compute_network" "vpc" {
  project = var.project_id
  name    = "${local.prefix}-vpc"

  # Disable auto-mode subnets; we create custom subnets explicitly so that we
  # control CIDR ranges and secondary ranges for GKE.
  auto_create_subnetworks = false

  # Enable global routing so that Cloud Routers in different regions can
  # advertise routes to each other (required for multi-region traffic).
  routing_mode = "GLOBAL"

  description = "X-IAM VPC for the ${var.environment} environment."
}

# ---------------------------------------------------------------------------
# Primary Subnet (Belgium -- europe-west1)
# ---------------------------------------------------------------------------

resource "google_compute_subnetwork" "primary" {
  project = var.project_id
  name    = "${local.prefix}-subnet-primary"
  region  = var.primary_region
  network = google_compute_network.vpc.id

  ip_cidr_range = var.vpc_cidr_primary

  # Enable VPC Flow Logs for network troubleshooting and security analysis.
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  # Private Google Access allows VMs without external IPs to reach Google APIs
  # and services (e.g. Container Registry, Cloud SQL Admin API).
  private_ip_google_access = true

  # Secondary ranges consumed by GKE for pod and service IPs.
  secondary_ip_range {
    range_name    = "${local.prefix}-pods-primary"
    ip_cidr_range = var.pods_cidr_primary
  }

  secondary_ip_range {
    range_name    = "${local.prefix}-services-primary"
    ip_cidr_range = var.services_cidr_primary
  }

  description = "Primary subnet (Belgium) for ${var.environment}."
}

# ---------------------------------------------------------------------------
# Secondary Subnet (Madrid -- europe-southwest1)  [prod multi-region only]
# ---------------------------------------------------------------------------

resource "google_compute_subnetwork" "secondary" {
  count = var.multi_region_enabled ? 1 : 0

  project = var.project_id
  name    = "${local.prefix}-subnet-secondary"
  region  = var.secondary_region
  network = google_compute_network.vpc.id

  ip_cidr_range = var.vpc_cidr_secondary

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "${local.prefix}-pods-secondary"
    ip_cidr_range = var.pods_cidr_secondary
  }

  secondary_ip_range {
    range_name    = "${local.prefix}-services-secondary"
    ip_cidr_range = var.services_cidr_secondary
  }

  description = "Secondary subnet (Madrid) for ${var.environment}."
}

# ---------------------------------------------------------------------------
# Cloud Router + NAT -- Primary Region
# ---------------------------------------------------------------------------
# Private GKE nodes require Cloud NAT to pull container images, reach
# external OIDC providers, and download Helm charts.

resource "google_compute_router" "primary" {
  project = var.project_id
  name    = "${local.prefix}-router-primary"
  region  = var.primary_region
  network = google_compute_network.vpc.id

  description = "Cloud Router for NAT in ${var.primary_region}."
}

resource "google_compute_router_nat" "primary" {
  project = var.project_id
  name    = "${local.prefix}-nat-primary"
  router  = google_compute_router.primary.name
  region  = var.primary_region

  # Automatically allocate external IPs for NAT; simpler than reserving static
  # addresses and sufficient for most workloads.
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ---------------------------------------------------------------------------
# Cloud Router + NAT -- Secondary Region  [prod multi-region only]
# ---------------------------------------------------------------------------

resource "google_compute_router" "secondary" {
  count = var.multi_region_enabled ? 1 : 0

  project = var.project_id
  name    = "${local.prefix}-router-secondary"
  region  = var.secondary_region
  network = google_compute_network.vpc.id

  description = "Cloud Router for NAT in ${var.secondary_region}."
}

resource "google_compute_router_nat" "secondary" {
  count = var.multi_region_enabled ? 1 : 0

  project = var.project_id
  name    = "${local.prefix}-nat-secondary"
  router  = google_compute_router.secondary[0].name
  region  = var.secondary_region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ---------------------------------------------------------------------------
# Firewall Rules
# ---------------------------------------------------------------------------

# Allow Google Cloud health-check probes to reach any instance.  These source
# ranges are documented by Google and are required for GKE Ingress, load
# balancers, and managed instance group auto-healing.
resource "google_compute_firewall" "allow_health_checks" {
  project = var.project_id
  name    = "${local.prefix}-allow-health-checks"
  network = google_compute_network.vpc.id

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    "35.191.0.0/16",   # Health-check probes
    "130.211.0.0/22",  # Legacy health-check probes
  ]

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080", "8443", "9000"]
  }

  description = "Allow GCP health-check probes to backend services."

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow IAP (Identity-Aware Proxy) tunnelled SSH for secure bastion-less
# access to GKE nodes and other VMs.
resource "google_compute_firewall" "allow_iap_ssh" {
  project = var.project_id
  name    = "${local.prefix}-allow-iap-ssh"
  network = google_compute_network.vpc.id

  direction = "INGRESS"
  priority  = 1000

  # IAP tunnel source range.
  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  description = "Allow SSH via Identity-Aware Proxy tunnelling."

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow all internal traffic between nodes, pods, and services within the VPC.
# This is required for pod-to-pod communication and for GKE node-to-control-
# plane connectivity.
resource "google_compute_firewall" "allow_internal" {
  project = var.project_id
  name    = "${local.prefix}-allow-internal"
  network = google_compute_network.vpc.id

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    var.vpc_cidr_primary,
    var.pods_cidr_primary,
    var.services_cidr_primary,
    var.multi_region_enabled ? var.vpc_cidr_secondary : var.vpc_cidr_primary,
    var.multi_region_enabled ? var.pods_cidr_secondary : var.pods_cidr_primary,
    var.multi_region_enabled ? var.services_cidr_secondary : var.services_cidr_primary,
  ]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  description = "Allow all internal VPC traffic (nodes, pods, services)."

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Deny all other ingress by default (GCP default network allows SSH and RDP;
# our custom VPC does not, but this explicit rule makes intent clear).
resource "google_compute_firewall" "deny_all_ingress" {
  project = var.project_id
  name    = "${local.prefix}-deny-all-ingress"
  network = google_compute_network.vpc.id

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }

  description = "Default deny all ingress -- explicit allowlists above take precedence."
}

# ---------------------------------------------------------------------------
# Private Service Access -- Cloud SQL
# ---------------------------------------------------------------------------
# Reserve an IP range inside the VPC for Google-managed services (Cloud SQL,
# Memorystore, etc.) and create a private VPC peering connection so that
# Cloud SQL instances get private IPs reachable from within the VPC.

resource "google_compute_global_address" "private_services_range" {
  project = var.project_id
  name    = "${local.prefix}-private-svc-range"

  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = google_compute_network.vpc.id

  description = "Reserved IP range for Private Service Access (Cloud SQL, etc.)."
}

resource "google_service_networking_connection" "private_services" {
  network = google_compute_network.vpc.id

  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services_range.name]
}
