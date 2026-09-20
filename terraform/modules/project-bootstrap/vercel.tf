resource "vercel_project" "app" {
  name      = var.project_name
  framework = "nextjs"
  team_id   = var.vercel_team_id

  git_repository = {
    type = "github"
    repo = "${var.github_owner}/${var.project_name}"
  }

  auto_assign_custom_domains = false

  git_comments = {
    on_commit       = false
    on_pull_request = true
  }

  vercel_authentication = {
    deployment_type = "standard_protection_new"
  }

  protection_bypass_for_automation = true
}

resource "vercel_project_domain" "www" {
  count      = var.production_domain == null ? 0 : 1
  project_id = vercel_project.app.id
  team_id    = var.vercel_team_id
  domain     = "www.${var.production_domain}"
}

resource "vercel_project_domain" "apex" {
  count      = var.production_domain == null || !var.add_www_redirect ? 0 : 1
  project_id = vercel_project.app.id
  team_id    = var.vercel_team_id
  domain     = var.production_domain

  redirect             = vercel_project_domain.www[0].domain
  redirect_status_code = 308
}

resource "vercel_project_environment_variable" "database_url_production" {
  project_id = vercel_project.app.id
  team_id    = var.vercel_team_id
  key        = "DATABASE_URL"
  value      = neon_project.app.connection_uri_pooler
  target     = ["production"]
  sensitive  = true
}

resource "vercel_project_environment_variable" "database_url_unpooled_production" {
  project_id = vercel_project.app.id
  team_id    = var.vercel_team_id
  key        = "DATABASE_URL_UNPOOLED"
  value      = neon_project.app.connection_uri
  target     = ["production"]
  sensitive  = true
}

resource "vercel_project_environment_variable" "database_url_preview" {
  project_id = vercel_project.app.id
  team_id    = var.vercel_team_id
  key        = "DATABASE_URL"
  value      = local.preview_database_url
  target     = ["preview"]
  sensitive  = true
}

resource "vercel_project_environment_variable" "database_url_unpooled_preview" {
  project_id = vercel_project.app.id
  team_id    = var.vercel_team_id
  key        = "DATABASE_URL_UNPOOLED"
  value      = local.preview_database_url_unpooled
  target     = ["preview"]
  sensitive  = true
}

resource "vercel_project_environment_variable" "clerk_publishable_key_preview" {
  count      = var.clerk_publishable_key == null ? 0 : 1
  project_id = vercel_project.app.id
  team_id    = var.vercel_team_id
  key        = "NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY"
  value      = var.clerk_publishable_key
  target     = ["preview", "development"]
  sensitive  = false
}

resource "vercel_project_environment_variable" "clerk_secret_key_preview" {
  count      = var.clerk_secret_key == null ? 0 : 1
  project_id = vercel_project.app.id
  team_id    = var.vercel_team_id
  key        = "CLERK_SECRET_KEY"
  value      = var.clerk_secret_key
  target     = ["preview"]
  sensitive  = true
}

resource "vercel_project_environment_variable" "clerk_publishable_key_production" {
  count      = var.clerk_production_publishable_key == null ? 0 : 1
  project_id = vercel_project.app.id
  team_id    = var.vercel_team_id
  key        = "NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY"
  value      = var.clerk_production_publishable_key
  target     = ["production"]
  sensitive  = false
}

resource "vercel_project_environment_variable" "clerk_secret_key_production" {
  count      = var.clerk_production_secret_key == null ? 0 : 1
  project_id = vercel_project.app.id
  team_id    = var.vercel_team_id
  key        = "CLERK_SECRET_KEY"
  value      = var.clerk_production_secret_key
  target     = ["production"]
  sensitive  = true
}

resource "vercel_project_environment_variable" "clerk_webhook_signing_secret_production" {
  count      = var.clerk_production_webhook_signing_secret == null ? 0 : 1
  project_id = vercel_project.app.id
  team_id    = var.vercel_team_id
  key        = "CLERK_WEBHOOK_SIGNING_SECRET"
  value      = var.clerk_production_webhook_signing_secret
  target     = ["production"]
  sensitive  = true
}

locals {
  clerk_url_env_vars = {
    NEXT_PUBLIC_CLERK_SIGN_IN_URL                   = var.clerk_sign_in_url
    NEXT_PUBLIC_CLERK_SIGN_UP_URL                   = var.clerk_sign_up_url
    NEXT_PUBLIC_CLERK_SIGN_IN_FALLBACK_REDIRECT_URL = "/"
    NEXT_PUBLIC_CLERK_SIGN_UP_FALLBACK_REDIRECT_URL = "/"
  }
}

resource "vercel_project_environment_variable" "clerk_urls" {
  for_each   = local.clerk_url_env_vars
  project_id = vercel_project.app.id
  team_id    = var.vercel_team_id
  key        = each.key
  value      = each.value
  target     = ["production", "preview", "development"]
  sensitive  = false
}

resource "vercel_project_environment_variable" "extra_production" {
  for_each   = nonsensitive(toset(keys(var.extra_production_env_vars)))
  project_id = vercel_project.app.id
  team_id    = var.vercel_team_id
  key        = each.value
  value      = var.extra_production_env_vars[each.value]
  target     = ["production"]
  sensitive  = true
}
