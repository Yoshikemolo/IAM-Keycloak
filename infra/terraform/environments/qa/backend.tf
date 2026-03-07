# -----------------------------------------------------------------------------
# X-IAM Platform -- QA Environment -- Remote State Backend
# -----------------------------------------------------------------------------

terraform {
  backend "gcs" {
    bucket = "xiam-terraform-state-qa"
    prefix = "terraform/state"
  }
}
