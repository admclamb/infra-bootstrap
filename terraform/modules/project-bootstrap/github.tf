data "github_user" "admin" {
  username = var.github_admin_username
}

resource "github_repository" "app" {
  name                   = var.project_name
  visibility             = "private"
  auto_init              = true
  allow_squash_merge     = true
  allow_merge_commit     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true
}

resource "github_repository_vulnerability_alerts" "app" {
  repository = github_repository.app.name
  enabled    = true
}

resource "github_repository_dependabot_security_updates" "app" {
  repository = github_repository.app.name
  enabled    = true
}

resource "github_repository_file" "codeowners" {
  repository          = github_repository.app.name
  branch              = "main"
  file                = ".github/CODEOWNERS"
  content             = "* @${var.github_admin_username}\n"
  commit_message      = "Add CODEOWNERS"
  overwrite_on_create = true
}

resource "github_actions_repository_permissions" "app" {
  repository           = github_repository.app.name
  allowed_actions      = "selected"
  sha_pinning_required = true

  allowed_actions_config {
    github_owned_allowed = true
    verified_allowed     = false
    patterns_allowed     = []
  }
}

resource "github_repository_ruleset" "main" {
  name        = "main"
  repository  = github_repository.app.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion                = true
    non_fast_forward        = true
    required_linear_history = var.require_linear_history

    pull_request {
      required_approving_review_count = var.required_approving_review_count
      require_code_owner_review       = var.require_code_owner_review
      dismiss_stale_reviews_on_push   = false
      allowed_merge_methods           = ["merge", "squash", "rebase"]
    }

    required_status_checks {
      strict_required_status_checks_policy = false
      do_not_enforce_on_create             = false

      dynamic "required_check" {
        for_each = var.required_status_check_contexts
        content {
          context = required_check.value
        }
      }
    }
  }
}

resource "github_repository_environment" "production" {
  repository          = github_repository.app.name
  environment         = "Production"
  prevent_self_review = false

  reviewers {
    users = [data.github_user.admin.id]
  }
}

resource "github_actions_environment_secret" "vercel_token" {
  repository  = github_repository.app.name
  environment = github_repository_environment.production.environment
  secret_name = "VERCEL_TOKEN"
  value       = var.vercel_api_token
}

resource "github_actions_environment_secret" "vercel_org_id" {
  count       = var.vercel_team_id == null ? 0 : 1
  repository  = github_repository.app.name
  environment = github_repository_environment.production.environment
  secret_name = "VERCEL_ORG_ID"
  value       = var.vercel_team_id
}

resource "github_actions_environment_secret" "vercel_project_id" {
  repository  = github_repository.app.name
  environment = github_repository_environment.production.environment
  secret_name = "VERCEL_PROJECT_ID"
  value       = vercel_project.app.id
}

resource "github_actions_secret" "vercel_automation_bypass_secret" {
  repository  = github_repository.app.name
  secret_name = "VERCEL_AUTOMATION_BYPASS_SECRET"
  value       = vercel_project.app.protection_bypass_for_automation_secret
}

resource "github_actions_secret" "clerk_publishable_key" {
  count       = var.clerk_publishable_key == null ? 0 : 1
  repository  = github_repository.app.name
  secret_name = "CLERK_PUBLISHABLE_KEY"
  value       = var.clerk_publishable_key
}

resource "github_actions_secret" "clerk_secret_key" {
  count       = var.clerk_secret_key == null ? 0 : 1
  repository  = github_repository.app.name
  secret_name = "CLERK_SECRET_KEY"
  value       = var.clerk_secret_key
}
