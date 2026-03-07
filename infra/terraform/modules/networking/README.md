# Networking Module

## Overview

Creates the foundational network layer for the X-IAM platform on Google Cloud Platform (GCP).

## Resources Created

| Resource | Description |
|----------|-------------|
| `google_compute_network` | Custom-mode VPC with global routing |
| `google_compute_subnetwork` (primary) | Subnet in europe-west1 with pod/service secondary ranges |
| `google_compute_subnetwork` (secondary) | Subnet in europe-southwest1 (prod only) |
| `google_compute_router` + `google_compute_router_nat` | Cloud NAT for private node egress |
| `google_compute_firewall` | Health checks, IAP SSH, internal traffic, default deny |
| `google_compute_global_address` + `google_service_networking_connection` | Private Service Access for Cloud SQL |

## Multi-Region

When `multi_region_enabled = true` (typically production), the module creates a second subnet, Cloud Router, and NAT gateway in the secondary region. The VPC uses global routing so that routes are shared across regions.

## IP Address Plan

| Range | Primary Region | Secondary Region |
|-------|---------------|-----------------|
| Nodes | 10.0.0.0/20 | 10.0.16.0/20 |
| Pods | 10.4.0.0/14 | 10.12.0.0/14 |
| Services | 10.8.0.0/20 | 10.16.0.0/20 |
| Private Services (Cloud SQL) | /20 auto-allocated | -- |

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"

  project_id           = var.project_id
  environment          = "prod"
  org_name             = "xiam"
  primary_region       = "europe-west1"
  secondary_region     = "europe-southwest1"
  multi_region_enabled = true

  vpc_cidr_primary      = "10.0.0.0/20"
  vpc_cidr_secondary    = "10.0.16.0/20"
  pods_cidr_primary     = "10.4.0.0/14"
  services_cidr_primary = "10.8.0.0/20"
  pods_cidr_secondary   = "10.12.0.0/14"
  services_cidr_secondary = "10.16.0.0/20"
}
```
