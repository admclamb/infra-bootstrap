variable "project_name" {
  type = string
}

variable "github_owner" {
  type = string
}

variable "github_admin_username" {
  type = string
}

variable "vercel_api_token" {
  type      = string
  sensitive = true
}

variable "vercel_team_id" {
  type    = string
  default = null
}

variable "production_domain" {
  type    = string
  default = null
}

variable "add_www_redirect" {
  type    = bool
  default = true
}

variable "neon_org_id" {
  type    = string
  default = null
}

variable "neon_region_id" {
  type    = string
  default = "aws-us-east-1"
}

variable "required_status_check_contexts" {
  type    = list(string)
  default = ["Build"]
}

variable "require_code_owner_review" {
  type    = bool
  default = true
}

variable "required_approving_review_count" {
  type    = number
  default = 0
}

variable "require_linear_history" {
  type    = bool
  default = false
}

variable "clerk_publishable_key" {
  type      = string
  default   = null
  sensitive = true
}

variable "clerk_secret_key" {
  type      = string
  default   = null
  sensitive = true
}

variable "clerk_webhook_signing_secret" {
  type      = string
  default   = null
  sensitive = true
}

variable "clerk_production_publishable_key" {
  description = "Live-mode (pk_live_) key for Vercel's Production environment. Leave null to run Production on the dev instance too, for now."
  type        = string
  default     = null
  sensitive   = true
}

variable "clerk_production_secret_key" {
  type      = string
  default   = null
  sensitive = true
}

variable "clerk_production_webhook_signing_secret" {
  type      = string
  default   = null
  sensitive = true
}

variable "clerk_sign_in_url" {
  type    = string
  default = "/sign-in"
}

variable "clerk_sign_up_url" {
  type    = string
  default = "/sign-up"
}

variable "extra_production_env_vars" {
  description = "Extra sensitive env vars for the Production environment only, e.g. app-specific API keys."
  type        = map(string)
  default     = {}
  sensitive   = true
}
