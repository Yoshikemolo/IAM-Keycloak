# -----------------------------------------------------------------------------
# X-IAM Platform -- Prod Environment -- Remote State Backend
# -----------------------------------------------------------------------------

terraform {
  backend "gcs" {
    bucket = "xiam-terraform-state-prod"
    prefix = "terraform/state"
  }
}
