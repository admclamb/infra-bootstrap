output "github_repository_url" {
  value = github_repository.app.html_url
}

output "vercel_project_id" {
  value = vercel_project.app.id
}

output "neon_project_id" {
  value = neon_project.app.id
}

output "neon_production_database_url" {
  value     = neon_project.app.connection_uri_pooler
  sensitive = true
}

output "neon_preview_database_url" {
  value     = local.preview_database_url
  sensitive = true
}

output "vercel_automation_bypass_secret" {
  value     = vercel_project.app.protection_bypass_for_automation_secret
  sensitive = true
}
