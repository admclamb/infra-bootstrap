output "github_repository_url" {
  value = module.stack_duel.github_repository_url
}

output "vercel_project_id" {
  value = module.stack_duel.vercel_project_id
}

output "neon_project_id" {
  value = module.stack_duel.neon_project_id
}

output "vercel_automation_bypass_secret" {
  value     = module.stack_duel.vercel_automation_bypass_secret
  sensitive = true
}
