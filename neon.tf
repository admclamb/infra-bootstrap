resource "neon_project" "app" {
  name      = var.project_name
  org_id    = var.neon_org_id
  region_id = var.neon_region_id

  branch {
    name = "main"
  }
}

resource "neon_branch" "preview" {
  project_id = neon_project.app.id
  parent_id  = neon_project.app.default_branch_id
  name       = "preview"
}

resource "neon_role" "preview" {
  project_id = neon_project.app.id
  branch_id  = neon_branch.preview.id
  name       = neon_project.app.database_user
}

resource "neon_database" "preview" {
  project_id = neon_project.app.id
  branch_id  = neon_branch.preview.id
  name       = neon_project.app.database_name
  owner_name = neon_role.preview.name
}

resource "neon_endpoint" "preview" {
  project_id = neon_project.app.id
  branch_id  = neon_branch.preview.id
  type       = "read_write"
}

locals {
  preview_database_url          = "postgresql://${neon_role.preview.name}:${neon_role.preview.password}@${neon_endpoint.preview.host_pooling}/${neon_database.preview.name}?sslmode=require"
  preview_database_url_unpooled = "postgresql://${neon_role.preview.name}:${neon_role.preview.password}@${neon_endpoint.preview.host}/${neon_database.preview.name}?sslmode=require"
}
