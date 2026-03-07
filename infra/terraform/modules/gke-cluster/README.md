# GKE Cluster Module

## Overview

Provisions a private Google Kubernetes Engine (GKE) cluster with two managed node pools optimised for the X-IAM Keycloak platform.

## Node Pools

| Pool | Purpose | Taint | Default Machine |
|------|---------|-------|----------------|
| `system` | Infrastructure workloads (ingress, cert-manager, observability) | None | e2-standard-2 |
| `keycloak` | Dedicated Keycloak pods | `workload=keycloak:NoSchedule` | e2-standard-4 |

## Security Features

- Private nodes (no external IPs)
- Shielded nodes (Secure Boot + Integrity Monitoring)
- Workload Identity (per-pod GCP credentials)
- Binary Authorization (audit or enforce mode)
- Dataplane V2 / Cilium (network policy enforcement)
- Disabled legacy metadata endpoints

## Usage

```hcl
module "gke_primary" {
  source = "../../modules/gke-cluster"

  project_id   = var.project_id
  environment  = "prod"
  org_name     = "xiam"
  region       = "europe-west1"
  region_short = "ew1"

  vpc_id              = module.networking.vpc_id
  subnet_id           = module.networking.primary_subnet_id
  pods_range_name     = module.networking.pods_range_name_primary
  services_range_name = module.networking.services_range_name_primary

  system_node_machine_type   = "e2-standard-4"
  keycloak_node_machine_type = "e2-standard-8"
}
```
