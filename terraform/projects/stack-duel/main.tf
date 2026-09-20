module "stack_duel" {
  source = "../../modules/project-bootstrap"

  project_name          = "stack-duel"
  github_owner          = "admclamb"
  github_admin_username = "admclamb"

  vercel_api_token = var.vercel_api_token

  production_domain = "stackduel.dev"
  add_www_redirect  = true

  neon_region_id = "aws-us-east-1"

  clerk_publishable_key        = var.clerk_publishable_key
  clerk_secret_key             = var.clerk_secret_key
  clerk_webhook_signing_secret = var.clerk_webhook_signing_secret

  clerk_production_publishable_key        = var.clerk_production_publishable_key
  clerk_production_secret_key             = var.clerk_production_secret_key
  clerk_production_webhook_signing_secret = var.clerk_production_webhook_signing_secret
}
