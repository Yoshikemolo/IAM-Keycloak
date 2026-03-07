# -----------------------------------------------------------------------------
# X-IAM Platform -- Remote State Backend (GCS)
# -----------------------------------------------------------------------------
# The root module declares the backend block as a placeholder.  Each
# environment directory (environments/dev, environments/qa, environments/prod)
# supplies its own backend.tf that points to an environment-specific GCS bucket
# and prefix, ensuring complete state isolation between environments.
#
# IMPORTANT: This file is NOT used directly.  It exists as documentation of the
# pattern.  Run "terraform init" from an environment directory, never from the
# root.
# -----------------------------------------------------------------------------

# terraform {
#   backend "gcs" {
#     bucket = "xiam-terraform-state-<env>"
#     prefix = "terraform/state"
#   }
# }
