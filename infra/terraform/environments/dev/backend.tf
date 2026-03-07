# -----------------------------------------------------------------------------
# X-IAM Platform -- Dev Environment -- Remote State Backend
# -----------------------------------------------------------------------------

terraform {
  backend "gcs" {
    bucket = "xiam-terraform-state-dev"
    prefix = "terraform/state"
  }
}
